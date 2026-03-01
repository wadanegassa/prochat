import 'package:flutter/material.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../friends/friends_screen.dart';
import '../groups/groups_screen.dart';
import '../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatListScreen(),
    const GroupsScreen(),
    const ContactsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.rose;

    return Scaffold(
      body: PageTransitions(_screens[_selectedIndex]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
        color: Colors.transparent,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B2E) : Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF424242) : AppTheme.brown.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.bubble_chart_outlined, Icons.bubble_chart_rounded, activeColor, isDark), // Chats
              _buildNavItem(1, Icons.hub_outlined, Icons.hub_rounded, activeColor, isDark), // Groups
              _buildNavItem(2, Icons.diversity_1_outlined, Icons.diversity_1_rounded, activeColor, isDark), // Contacts
              _buildNavItem(3, Icons.fingerprint_rounded, Icons.fingerprint_rounded, activeColor, isDark), // Profile
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, Color activeColor, bool isDark) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.35)
                  : Colors.transparent,
              blurRadius: isSelected ? 18 : 0,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected 
              ? Colors.white 
              : (isDark ? const Color(0xFF9E9E9E) : AppTheme.brown.withValues(alpha: 0.5)),
          size: isSelected ? 22 : 26,
        ),
      ),
    );
  }
}

class PageTransitions extends StatelessWidget {
  final Widget child;
  const PageTransitions(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}
