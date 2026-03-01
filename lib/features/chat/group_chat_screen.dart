import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/group_model.dart';
import '../../core/services/chat_service.dart';
import 'widgets/chat_input.dart';
import 'widgets/message_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  String? _editingMessageId;
  String? _editingText;

  void _startEditing(MessageModel message) {
    setState(() {
      _editingMessageId = message.id;
      _editingText = message.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessageId = null;
      _editingText = null;
    });
  }

  void _onMessageLongPress(MessageModel message, bool isMe) {
    if (!isMe) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppTheme.brown.withValues(alpha: 0.06);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: divColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: AppTheme.vibrantBlue, size: 18),
              ),
              title: Text('Edit Message',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _startEditing(message);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
              ),
              title: const Text('Delete Message',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(message);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MessageModel message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final subColor =
        isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Delete Message?',
            style: TextStyle(
                color: textColor, fontSize: 17, fontWeight: FontWeight.w900)),
        content: Text('This cannot be undone.',
            style: TextStyle(color: subColor, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: subColor, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final chatProvider =
                  Provider.of<ChatProvider>(context, listen: false);
              chatProvider.deleteGroupMessage(
                  widget.groupId, message.id, false, authProvider.userModel!.uid);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).userModel;
    final chatProvider = Provider.of<ChatProvider>(context);

    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.vibrantBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.groups_rounded,
                  color: AppTheme.vibrantBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                  StreamBuilder<GroupModel?>(
                    stream: ChatService().getGroupStream(widget.groupId),
                    builder: (context, snapshot) {
                      final membersCount = snapshot.data?.members.length ?? 0;
                      return Text(
                        '$membersCount members',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brown.withValues(alpha: 0.45),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatProvider.getGroupMessages(widget.groupId, currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error loading messages'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 48, color: const Color(0xFF424242)),
                        const SizedBox(height: 16),
                        Text('No messages yet', style: TextStyle(color: const Color(0xFF9E9E9E))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == currentUser.uid,
                      senderName: message.senderName,
                      onLongPress: () => _onMessageLongPress(
                          message, message.senderId == currentUser.uid),
                    );
                  },
                  reverse: true,
                );
              },
            ),
          ),
          ChatInput(
            senderId: currentUser.uid,
            receiverId: '', // Empty because it's a group
            groupId: widget.groupId,
            editingMessageId: _editingMessageId,
            editingText: _editingText,
            onCancelEditing: _cancelEditing,
          ),
        ],
      ),
    );
  }
}
