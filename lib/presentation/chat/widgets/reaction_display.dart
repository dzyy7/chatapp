import 'package:flutter/material.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/core/constants/app_colors.dart';

class ReactionDisplay extends StatelessWidget {
  final ChatMessage message;
  final String? currentUserId;
  final bool isMine;
  final void Function(String emoji) onTap;

  const ReactionDisplay({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.isMine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = message.groupedReactions;
    if (grouped.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: isMine ? 0 : 4,
        right: isMine ? 4 : 0,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: isMine ? WrapAlignment.end : WrapAlignment.start,
        children: grouped.entries.map((entry) {
          final emoji = entry.key;
          final reactors = entry.value;
          final count = reactors.length;
          final iReacted = currentUserId != null &&
              reactors.any((r) => r.userId == currentUserId);

          return GestureDetector(
            onTap: () => onTap(emoji),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: iReacted
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: iReacted
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 13)),
                  if (count > 1) ...[
                    const SizedBox(width: 3),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: iReacted
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}