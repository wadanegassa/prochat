import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _chatService = ChatService();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final List<String> _selectedUserIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userModel;
    
    if (currentUser != null) {
      final members = [..._selectedUserIds, currentUser.uid];
      
      try {
        await _chatService.createGroup(
          _nameController.text.trim(),
          members,
          currentUser.uid,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating group: $e')),
          );
        }
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _createGroup,
              child: const Text('CREATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter group name...',
                prefixIcon: Icon(Icons.groups_rounded, color: AppTheme.vibrantBlue),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text('SELECT MEMBERS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                        letterSpacing: 1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: Icon(Icons.search_rounded,
                    color: isDark
                        ? const Color(0xFF9E9E9E)
                        : AppTheme.brown.withValues(alpha: 0.3),
                    size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _chatService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final currentUser = authProvider.userModel;
                final query = _searchController.text.toLowerCase();
                final users = snapshot.data
                        ?.where((u) =>
                            u.uid != currentUser?.uid &&
                            u.name.toLowerCase().contains(query))
                        .toList() ??
                    [];

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                        _searchController.text.isEmpty
                            ? 'No users found'
                            : 'No results for "${_searchController.text}"',
                        style: TextStyle(color: Colors.grey.withValues(alpha: 0.5))),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.uid);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedUserIds.remove(user.uid);
                          } else {
                            _selectedUserIds.add(user.uid);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.vibrantBlue.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.vibrantBlue : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.rose.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: (user.photoUrl.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        user.photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            user.name.isNotEmpty
                                                ? user.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                color: AppTheme.rose,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: AppTheme.rose,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppTheme.brown,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedUserIds.add(user.uid);
                                  } else {
                                    _selectedUserIds.remove(user.uid);
                                  }
                                });
                              },
                              activeColor: AppTheme.vibrantBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
