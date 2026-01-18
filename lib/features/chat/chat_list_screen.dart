import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/group_model.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../profile/profile_screen.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'group_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  late AuthProvider _authProvider;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _updateStatus(true);
  }

  @override
  void dispose() {
    _updateStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateStatus(true);
    } else {
      _updateStatus(false);
    }
  }

  void _updateStatus(bool isOnline) {
    if (_authProvider.isAuthenticated) {
      _authProvider.updateUserStatus(isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        flexibleSpace: Container(color: Theme.of(context).scaffoldBackgroundColor),
        title: const Text(
          'PROCHAT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            fontSize: 20,
            color: AppTheme.pureGold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppTheme.pureGold),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorWeight: 3,
          indicatorColor: AppTheme.pureGold,
          labelColor: AppTheme.pureGold,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26,
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'GROUPS'),
            Tab(text: 'PEOPLE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(),
          _buildGroupsTab(),
          _buildContactsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              backgroundColor: AppTheme.pureGold,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
              },
              child: const Icon(Icons.add_rounded, color: AppTheme.luxeBlack, size: 28),
            )
          : null,
    );
  }

  Widget _buildChatsTab() {
    final currentUser = _authProvider.userModel;
    if (currentUser == null) return const SizedBox();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getActiveChats(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading chats'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final rooms = snapshot.data ?? [];
        
        return RefreshIndicator(
          color: AppTheme.pureGold,
          backgroundColor: Theme.of(context).cardTheme.color,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 1000)),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
            final room = rooms[index];
            final partnerId = room['partnerId'] as String;
            final lastMessage = room['lastMessage'] as String;

            return StreamBuilder<UserModel?>(
              stream: _chatService.getUserStream(partnerId),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data;
                if (user == null) return const SizedBox.shrink();

                return _buildAnimatedCard(
                  index: index,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.pureGold.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.pureGold.withOpacity(0.1), width: 1),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: AppTheme.pureGold.withOpacity(0.05),
                              backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                              child: user.photoUrl.isEmpty ? Text(user.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.pureGold)) : null,
                            ),
                          ),
                          if (user.isOnline)
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.pureGold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).cardTheme.color!, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5),
                      ),
                      subtitle: Text(
                        lastMessage.isNotEmpty ? lastMessage : (user.isOnline ? 'Online now' : 'Offline'),
                        style: TextStyle(
                          color: lastMessage.isNotEmpty 
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38)
                              : (user.isOnline ? AppTheme.pureGold.withOpacity(0.6) : Colors.white24),
                          fontSize: 12,
                          fontWeight: lastMessage.isNotEmpty ? FontWeight.w500 : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: StreamBuilder<int>(
                        stream: _chatService.getUnreadCount(ChatService.getChatRoomId(currentUser.uid, user.uid), currentUser.uid),
                        builder: (context, unreadSnapshot) {
                          final count = unreadSnapshot.data ?? 0;
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.pureGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(color: AppTheme.luxeBlack, fontWeight: FontWeight.w900, fontSize: 10),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              receiverId: user.uid,
                              receiverName: user.name,
                              receiverPhotoUrl: user.photoUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    final currentUser = _authProvider.userModel;
    if (currentUser == null) return const SizedBox();

    return StreamBuilder<List<GroupModel>>(
      stream: _chatService.getGroups(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading groups'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final groups = snapshot.data ?? [];
        
        return RefreshIndicator(
          color: AppTheme.pureGold,
          backgroundColor: Theme.of(context).cardTheme.color,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 1000)),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
            itemCount: groups.length,
            itemBuilder: (context, index) {
            final group = groups[index];
            return _buildAnimatedCard(
              index: index,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.pureGold.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pureGold.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.groups_rounded, color: AppTheme.pureGold, size: 24),
                  ),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  subtitle: Text(
                    group.lastMessage,
                    style: const TextStyle(color: Colors.white24, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupChatScreen(
                          groupId: group.id,
                          groupName: group.name,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
            },
          ),
        );
      },
    );
  }

  Widget _buildContactsTab() {
    final currentUser = _authProvider.userModel;
    return StreamBuilder<List<UserModel>>(
      stream: _chatService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading people'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!
            .where((user) => user.uid != currentUser?.uid)
            .toList();

        return RefreshIndicator(
          color: AppTheme.pureGold,
          backgroundColor: Theme.of(context).cardTheme.color,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 1000)),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
            itemCount: users.length,
            itemBuilder: (context, index) {
            final user = users[index];
            return _buildAnimatedCard(
              index: index,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.pureGold.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.pureGold.withOpacity(0.1), width: 1),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.pureGold.withOpacity(0.05),
                          backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                          child: user.photoUrl.isEmpty ? Text(user.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.pureGold, fontWeight: FontWeight.w900, fontSize: 12)) : null,
                        ),
                      ),
                      if (user.isOnline)
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.pureGold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).cardTheme.color!, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  subtitle: Text(
                    user.isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(color: user.isOnline ? AppTheme.pureGold.withOpacity(0.6) : Colors.white24, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: user.uid,
                          receiverName: user.name,
                          receiverPhotoUrl: user.photoUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 400)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
