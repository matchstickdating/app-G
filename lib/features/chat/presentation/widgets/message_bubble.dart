import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isSentByMe;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sent message styling: high contrast, elegant neutral
    final sentBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final sentText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    // Received message styling
    final receivedBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final receivedText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final bgColor = isSentByMe ? sentBg : receivedBg;
    final textColor = isSentByMe ? sentText : receivedText;
    final timeStr = DateFormat('h:mm a').format(message.createdAt).toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isSentByMe ? 18 : 4),
                bottomRight: Radius.circular(isSentByMe ? 4 : 18),
              ),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.content != null && message.content!.isNotEmpty)
                  Text(
                    message.content!,
                    style: AppTypography.bodyLarge(color: textColor).copyWith(
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ).copyWith(fontSize: 10),
                    ),
                    if (isSentByMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 13,
                        color: message.isRead ? AppColors.accent : AppColors.lightTextTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
