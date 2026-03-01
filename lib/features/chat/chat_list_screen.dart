import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/chat_room.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  late AuthProvider _authProvider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Note: Global status update is handled by AuthProvider/AuthService
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    final currentUser = _authProvider.userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildSearchAndFilter(isDark),
          Expanded(
            child: _buildChatList(currentUser, isDark),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: const Text('Chats'),
      actions: [
        StreamBuilder<List<ChatRoom>>(
          stream: _chatService.getChatRooms(_authProvider.userModel!.uid),
          builder: (context, snapshot) {
            int totalUnread = 0;
            if (snapshot.hasData) {
              for (var room in snapshot.data!) {
                if (room.lastMessageSenderId != _authProvider.userModel!.uid) {
                  totalUnread += room.unreadCount;
                }
              }
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                _buildCircleAction(Icons.notifications_active_outlined, isDark),
                if (totalUnread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.rose,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        totalUnread > 9 ? '9+' : totalUnread.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, bool isDark) {
    final fgColor = isDark ? const Color(0xFFE0E0E0) : AppTheme.brown;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: fgColor, size: 22),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: Icon(Icons.search_rounded, 
            color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.3), 
            size: 22
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(UserModel currentUser, bool isDark) {
    return StreamBuilder<List<ChatRoom>>(
      stream: _chatService.getChatRooms(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildSkeletonLoaders();
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

        final rooms = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: rooms.length,
          itemBuilder: (context, index) => _buildModernChatTile(rooms[index], currentUser.uid, isDark),
        );
      },
    );
  }

  Widget _buildModernChatTile(ChatRoom room, String currentUserId, bool isDark) {
    final otherUserId = room.users.firstWhere((id) => id != currentUserId);

    return StreamBuilder<UserModel?>(
      stream: _chatService.getUserStream(otherUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? (snapshot.connectionState == ConnectionState.waiting ? 'Loading...' : 'Deleted User');
        
        if (_searchController.text.isNotEmpty && !name.toLowerCase().contains(_searchController.text.toLowerCase())) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: otherUserId,
                    receiverName: name,
                    receiverPhotoUrl: user?.photoUrl ?? '',
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.peach.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: (user?.photoUrl != null && user!.photoUrl.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            user.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.rose,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.rose,
                                fontSize: 20),
                          ),
                        ),
                ),
                if (user?.isOnline ?? false)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.sage,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2.5),
                      ),
                    ),
                  )
                else if (room.unreadCount > 0 && room.lastMessageSenderId != currentUserId)
                   Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 17, 
                    color: isDark ? const Color(0xFFE0E0E0) : AppTheme.brown,
                  ),
                ),
                Text(
                  _formatTimestamp(room.lastMessageTime),
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.3), 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      room.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.4),
                        fontSize: 14,
                        fontWeight: (room.unreadCount > 0 && room.lastMessageSenderId != currentUserId) ? FontWeight.w900 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (room.unreadCount > 0 && room.lastMessageSenderId != currentUserId)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.vibrantBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        room.unreadCount.toString().padLeft(2, '0'),
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    )
                  else if (room.lastMessageSenderId == currentUserId)
                    Icon(
                      Icons.done_all_rounded, 
                      size: 16, 
                      color: isDark ? const Color(0xFF757575) : AppTheme.brown.withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (now.day == date.day) return '${date.hour}:${date.minute.toString().padLeft(2, '0')} PM';
    return '${date.day}/${date.month}';
  }

  Widget _buildSkeletonLoaders() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 84,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.softGrey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppTheme.brown.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(color: AppTheme.brown.withValues(alpha: 0.3), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
