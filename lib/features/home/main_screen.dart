import 'package:flutter/material.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../friends/friends_screen.dart';
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
    const FriendsScreen(),
    const ProfileScreen(),
    const Scaffold(body: Center(child: Text('Map'))), // Placeholder for the 4th icon in ref
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppTheme.peach : AppTheme.rose;

    return Scaffold(
      body: PageTransitions(_screens[_selectedIndex]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
        color: Colors.transparent,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.brown.withValues(alpha: 0.9) : Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppTheme.brown.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, activeColor),
              _buildNavItem(1, Icons.people_outline_rounded, Icons.people_rounded, activeColor),
              _buildNavItem(2, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, activeColor),
              _buildNavItem(3, Icons.location_on_outlined, Icons.location_on_rounded, activeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, Color activeColor) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.white : AppTheme.brown.withValues(alpha: 0.35),
          size: 24,
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
