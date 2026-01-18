import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/theme/app_theme.dart';
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppTheme.pureGold),
              title: const Text('EDIT MESSAGE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1)),
              onTap: () {
                Navigator.pop(context);
                _startEditing(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('DELETE MESSAGE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(message);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.luxeBlack,
        title: const Text('DELETE GROUP MESSAGE?', style: TextStyle(color: AppTheme.pureGold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: const Text('THIS ACTION CANNOT BE UNDONE.', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.deleteGroupMessage(widget.groupId, message.id, false, authProvider.userModel!.uid);
              Navigator.pop(context);
            },
            child: const Text('DELETE FOR ME', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.deleteGroupMessage(widget.groupId, message.id, true, authProvider.userModel!.uid);
              Navigator.pop(context);
            },
            child: const Text('DELETE FOR BOTH', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11)),
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
        flexibleSpace: Container(color: Theme.of(context).scaffoldBackgroundColor),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.group, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(widget.groupName),
          ],
        ),
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == currentUser.uid,
                      onLongPress: () => _onMessageLongPress(message, message.senderId == currentUser.uid),
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
