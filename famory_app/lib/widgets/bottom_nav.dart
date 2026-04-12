import 'package:flutter/material.dart';
import '../theme.dart';

class NavItem {
  final String id;
  final IconData icon;
  final String label;

  NavItem({required this.id, required this.icon, required this.label});
}

class BottomNav extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  final List<NavItem> tabs = [
    NavItem(id: 'home', icon: Icons.home_rounded, label: 'Home'),
    NavItem(id: 'chat', icon: Icons.chat_bubble_rounded, label: 'Chat'),
    NavItem(id: 'tasks', icon: Icons.check_box_rounded, label: 'Tasks'),
    NavItem(id: 'calendar', icon: Icons.calendar_today_rounded, label: 'Calendar'),
    NavItem(id: 'photos', icon: Icons.photo_rounded, label: 'Photos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          final isActive = activeTab == tab.id;
          return GestureDetector(
            onTap: () => onTabChange(tab.id),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.softBlueBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tab.icon,
                    size: 24,
                    color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 4 : 0,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
