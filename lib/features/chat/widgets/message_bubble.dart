import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/message_model.dart';
import '../../../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          final clampedValue = value.clamp(0.0, 1.0);
          return Opacity(
            opacity: clampedValue,
            child: Transform.translate(
              offset: Offset(isMe ? 20 * (1 - clampedValue) : -20 * (1 - clampedValue), 0),
              child: child,
            ),
          );
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe 
                  ? AppTheme.pureGold 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: isMe ? [
                BoxShadow(
                  color: AppTheme.pureGold.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe && message.senderName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderName.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.pureGold,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? AppTheme.luxeBlack : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    fontSize: 14,
                    fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        color: isMe ? AppTheme.luxeBlack.withOpacity(0.5) : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (message.isEdited)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'EDITED',
                          style: TextStyle(
                            color: isMe ? AppTheme.luxeBlack.withOpacity(0.4) : AppTheme.pureGold.withOpacity(0.5),
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Icon(
                        message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 12,
                        color: message.isRead ? AppTheme.luxeBlack : AppTheme.luxeBlack.withOpacity(0.2),
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
