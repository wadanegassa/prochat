import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          if (widget.groupId != null && widget.receiverId.isEmpty) {
            await chatProvider.updateGroupMessage(widget.groupId!, widget.editingMessageId!, text);
          } else {
            final roomId = ChatService.getChatRoomId(widget.senderId, widget.receiverId);
            await chatProvider.updateMessage(roomId, widget.editingMessageId!, text);
          }
          if (widget.onCancelEditing != null) widget.onCancelEditing!();
        } else {
          if (widget.groupId != null && widget.receiverId.isEmpty) {
            await chatProvider.sendGroupMessage(widget.groupId!, widget.senderId, currentUser.name, text);
          } else {
            await chatProvider.sendMessage(widget.senderId, currentUser.name, widget.receiverId, text, MessageType.text);
          }
        }
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingMessageId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: AppTheme.rose, size: 16),
                  const SizedBox(width: 8),
                  const Text('REVISING', style: TextStyle(color: AppTheme.rose, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const Spacer(),
                  GestureDetector(child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.brown), onTap: widget.onCancelEditing),
                ],
              ),
            ),
          Row(
            children: [
              _buildIconButton(Icons.add_rounded, isDark),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.brown.withValues(alpha: 0.4) : AppTheme.softGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: 4,
                          minLines: 1,
                          style: TextStyle(fontSize: 15, color: isDark ? AppTheme.peach : AppTheme.brown, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Message...',
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      _buildIconButton(Icons.emoji_emotions_outlined, isDark, size: 22),
                      _buildIconButton(Icons.mic_none_rounded, isDark, size: 22),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.sage,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.sage.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(
                    isEditing ? Icons.check_rounded : Icons.near_me_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isDark, {double size = 24}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Icon(
        icon,
        color: isDark ? AppTheme.peach.withValues(alpha: 0.5) : AppTheme.brown.withValues(alpha: 0.3),
        size: size,
      ),
    );
  }
}
