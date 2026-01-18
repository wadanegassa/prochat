import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/services/chat_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/chat_input.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhotoUrl;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
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
    if (!isMe) return; // Only allow editing/deleting own messages

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
        title: const Text('DELETE MESSAGE?', style: TextStyle(color: AppTheme.pureGold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: const Text('THIS ACTION CANNOT BE UNDONE.', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              final roomId = ChatService.getChatRoomId(authProvider.userModel!.uid, widget.receiverId);
              chatProvider.deleteMessage(roomId, message.id, false, authProvider.userModel!.uid);
              Navigator.pop(context);
            },
            child: const Text('DELETE FOR ME', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              final roomId = ChatService.getChatRoomId(authProvider.userModel!.uid, widget.receiverId);
              chatProvider.deleteMessage(roomId, message.id, true, authProvider.userModel!.uid);
              Navigator.pop(context);
            },
            child: const Text('DELETE FOR BOTH', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userModel;
    if (currentUser != null) {
      final roomId = ChatService.getChatRoomId(currentUser.uid, widget.receiverId);
      _chatService.markMessagesAsRead(roomId, currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).userModel;
    final chatProvider = Provider.of<ChatProvider>(context);

    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(color: Theme.of(context).scaffoldBackgroundColor),
        title: StreamBuilder<UserModel?>(
          stream: _chatService.getUserStream(widget.receiverId),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isOnline = user?.isOnline ?? false;
            final name = user?.name ?? widget.receiverName;
            final photoUrl = user?.photoUrl ?? widget.receiverPhotoUrl;

            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.pureGold.withOpacity(0.1), width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.pureGold.withOpacity(0.05),
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl.isEmpty
                        ? Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.pureGold))
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        isOnline ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          fontSize: 9, 
                          color: isOnline ? AppTheme.pureGold : Colors.white24, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatProvider.getMessages(currentUser.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error loading messages'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data ?? [];
                _markAsRead();

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
            receiverId: widget.receiverId,
            editingMessageId: _editingMessageId,
            editingText: _editingText,
            onCancelEditing: _cancelEditing,
          ),
        ],
      ),
    );
  }
}
