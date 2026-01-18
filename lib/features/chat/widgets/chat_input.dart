import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/models/message_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/chat_service.dart';

class ChatInput extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String? groupId;
  final String? editingMessageId;
  final String? editingText;
  final VoidCallback? onCancelEditing;

  const ChatInput({
    super.key,
    required this.senderId,
    required this.receiverId,
    this.groupId,
    this.editingMessageId,
    this.editingText,
    this.onCancelEditing,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingText != null && widget.editingText != oldWidget.editingText) {
      _controller.text = widget.editingText!;
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.userModel;

      if (currentUser != null) {
        if (widget.editingMessageId != null) {
          // Update message
          if (widget.groupId != null && widget.receiverId.isEmpty) {
            await chatProvider.updateGroupMessage(widget.groupId!, widget.editingMessageId!, text);
          } else {
            final roomId = ChatService.getChatRoomId(widget.senderId, widget.receiverId);
            await chatProvider.updateMessage(roomId, widget.editingMessageId!, text);
          }
          if (widget.onCancelEditing != null) widget.onCancelEditing!();
        } else {
          // Send new message
          if (widget.groupId != null && widget.receiverId.isEmpty) {
            await chatProvider.sendGroupMessage(
              widget.groupId!,
              widget.senderId,
              currentUser.name,
              text,
            );
          } else {
            await chatProvider.sendMessage(
              widget.senderId,
              currentUser.name,
              widget.receiverId,
              text,
              MessageType.text,
            );
          }
        }
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingMessageId != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppTheme.pureGold.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: AppTheme.pureGold, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EDITING MESSAGE',
                          style: TextStyle(
                            color: AppTheme.pureGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          widget.editingText ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white24),
                    onPressed: widget.onCancelEditing,
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: isEditing ? 'EDIT MESSAGE...' : 'WRITE A MESSAGE...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.pureGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.check_rounded : Icons.send_rounded,
                      color: AppTheme.luxeBlack,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
