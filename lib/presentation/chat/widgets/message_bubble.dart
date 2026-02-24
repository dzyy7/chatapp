import 'package:chatapp/presentation/chat/widgets/full_emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/core/constants/app_colors.dart';
import 'package:chatapp/data/models/chat_message.dart';
import 'package:chatapp/presentation/chat/bloc/chat_bloc.dart';
import 'package:chatapp/presentation/chat/bloc/chat_event.dart';
import 'package:chatapp/presentation/chat/widgets/emoji_reaction_picker.dart';
import 'package:chatapp/presentation/chat/widgets/reaction_display.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final String? currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    this.currentUserId,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool get isMine => widget.message.isMine;

  String? get _currentUserReaction {
    if (widget.currentUserId == null) return null;
    final found = widget.message.reactions.where(
      (r) => r.userId == widget.currentUserId,
    );
    return found.isNotEmpty ? found.first.emoji : null;
  }

  void _showReactionPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _ReactionPickerOverlay(
        layerLink: _layerLink,
        isMine: isMine,
        currentUserReaction: _currentUserReaction,
        onEmojiSelected: (emoji) {
          _removeOverlay();
          _handleEmojiSelected(context, emoji);
        },
        onMoreTap: () {
          _removeOverlay();
          FullEmojiPickerSheet.show(
            context,
            onEmojiSelected: (emoji) => _handleEmojiSelected(context, emoji),
          );
        },
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _handleEmojiSelected(BuildContext context, String emoji) {
    final messageId = widget.message.messageId;
    if (messageId == null) return;

    final bloc = context.read<ChatBloc>();

    if (_currentUserReaction == emoji) {
      // Toggle off — unreact
      bloc.add(ChatUnreactMessageEvent(messageId: messageId, emoji: emoji));
    } else {
      // If already reacted with different emoji, unreact first then react
      if (_currentUserReaction != null) {
        bloc.add(
          ChatUnreactMessageEvent(
            messageId: messageId,
            emoji: _currentUserReaction!,
          ),
        );
      }
      bloc.add(ChatReactMessageEvent(messageId: messageId, emoji: emoji));
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onLongPress: () => _showReactionPicker(context),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isMine
                      ? AppColors.sentMessage
                      : AppColors.receivedMessage,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMine && widget.message.userName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          widget.message.userName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    Text(
                      widget.message.isDeleted
                          ? '🚫 Message deleted'
                          : widget.message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.message.isDeleted
                            ? (isMine
                                  ? Colors.white60
                                  : AppColors.textSecondary)
                            : (isMine ? Colors.white : AppColors.textPrimary),
                        fontStyle: widget.message.isDeleted
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimeJakarta(widget.message.createdTime),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMine
                                ? Colors.white70
                                : AppColors.textHint,
                          ),
                        ),
                        if (widget.message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            '· edited',
                            style: TextStyle(
                              fontSize: 10,
                              color: isMine
                                  ? Colors.white60
                                  : AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reactions row below bubble
          if (widget.message.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ReactionDisplay(
                message: widget.message,
                currentUserId: widget.currentUserId,
                isMine: isMine,
                onTap: (emoji) => _handleEmojiSelected(context, emoji),
              ),
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _formatTimeJakarta(DateTime? utcTime) {
    if (utcTime == null) return '';
    try {
      final jakarta = tz.getLocation('Asia/Jakarta');
      final jakartaTime = tz.TZDateTime.from(utcTime, jakarta);
      return DateFormat('HH:mm').format(jakartaTime);
    } catch (e) {
      return DateFormat('HH:mm').format(utcTime.toLocal());
    }
  }
}

/// Overlay that shows the reaction picker above/below the bubble
class _ReactionPickerOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final bool isMine;
  final String? currentUserReaction;
  final void Function(String emoji) onEmojiSelected;
  final VoidCallback onMoreTap;
  final VoidCallback onDismiss;

  const _ReactionPickerOverlay({
    required this.layerLink,
    required this.isMine,
    required this.currentUserReaction,
    required this.onEmojiSelected,
    required this.onMoreTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed backdrop — tap to dismiss
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Picker positioned relative to bubble
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(isMine ? -220 : 0, -58),
          child: Material(
            color: Colors.transparent,
            child: EmojiReactionPicker(
              currentUserReaction: currentUserReaction,
              onEmojiSelected: onEmojiSelected,
              onMoreTap: onMoreTap,
            ),
          ),
        ),
      ],
    );
  }
}