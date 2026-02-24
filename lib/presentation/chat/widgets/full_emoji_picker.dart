import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:chatapp/core/constants/app_colors.dart';

class FullEmojiPickerSheet extends StatelessWidget {
  final void Function(String emoji) onEmojiSelected;

  const FullEmojiPickerSheet({super.key, required this.onEmojiSelected});

  static Future<void> show(
    BuildContext context, {
    required void Function(String emoji) onEmojiSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FullEmojiPickerSheet(onEmojiSelected: onEmojiSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          Expanded(
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                Navigator.of(context).pop();
                onEmojiSelected(emoji.emoji);
              },
              config: Config(
                height: 256,
                emojiViewConfig: EmojiViewConfig(
                  columns: 8,
                  emojiSizeMax: 28,
                  backgroundColor: Colors.white,
                ),
                categoryViewConfig: CategoryViewConfig(
                  initCategory: Category.SMILEYS,
                  indicatorColor: AppColors.primary,
                  iconColor: Colors.grey,
                  iconColorSelected: AppColors.primary,
                  backgroundColor: Colors.white,
                ),
                bottomActionBarConfig: const BottomActionBarConfig(
                  showSearchViewButton: true,
                  backgroundColor: Colors.white,
                  buttonColor: Colors.white,
                  buttonIconColor: Colors.grey,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: Colors.white,
                  buttonIconColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}