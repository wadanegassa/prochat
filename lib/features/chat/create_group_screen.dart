import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/chat_service.dart';
import '../../providers/auth_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _chatService = ChatService();
  final _nameController = TextEditingController();
  final List<String> _selectedUserIds = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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

    final currentUser = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (currentUser != null) {
      // Add current user to members
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _createGroup,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Select Members', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _chatService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final currentUser = Provider.of<AuthProvider>(context, listen: false).userModel;
                final users = snapshot.data?.where((u) => u.uid != currentUser?.uid).toList() ?? [];

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.uid);
                    
                    return CheckboxListTile(
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
                      title: Text(user.name),
                      secondary: CircleAvatar(
                        backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                        child: user.photoUrl.isEmpty ? Text(user.name[0].toUpperCase()) : null,
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
