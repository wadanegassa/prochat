import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/group_model.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../chat/group_chat_screen.dart';
import '../chat/create_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final query = _searchCtrl.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? const Color(0xFF9E9E9E)
                        : AppTheme.brown.withValues(alpha: 0.3),
                    size: 22,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<GroupModel>>(
                stream: _chatService.getGroups(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  final groups = snapshot.data!
                      .where((g) => g.name.toLowerCase().contains(query))
                      .toList();

                  if (groups.isEmpty) {
                    return Center(
                      child: Text(
                        'No groups match "${ _searchCtrl.text}"',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF9E9E9E)
                              : AppTheme.brown.withValues(alpha: 0.4),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) =>
                        _buildGroupCard(ctx, groups[i], isDark),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
        backgroundColor: AppTheme.rose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Group',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 4,
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, GroupModel group, bool isDark) {
    final memberCount = group.members.length;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GroupChatScreen(groupId: group.id, groupName: group.name),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.rose.withValues(alpha: 0.15),
                    AppTheme.peach.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.groups_rounded, color: AppTheme.rose, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDark ? const Color(0xFFE0E0E0) : AppTheme.brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF757575)
                              : AppTheme.brown.withValues(alpha: 0.35)),
                      const SizedBox(width: 4),
                      Text(
                        '$memberCount member${memberCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF757575)
                              : AppTheme.brown.withValues(alpha: 0.35),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (group.lastMessage.isNotEmpty) ...[
                        Text(
                          '  ·  ',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF424242)
                                : AppTheme.brown.withValues(alpha: 0.2),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            group.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF9E9E9E)
                                  : AppTheme.brown.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? const Color(0xFF424242)
                  : AppTheme.brown.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.rose.withValues(alpha: isDark ? 0.08 : 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_3_outlined,
              size: 44,
              color: AppTheme.rose.withValues(alpha: isDark ? 0.5 : 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? const Color(0xFF9E9E9E)
                  : AppTheme.brown.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a group to chat together',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFF616161)
                  : AppTheme.brown.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}
