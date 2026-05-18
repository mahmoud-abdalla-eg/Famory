import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

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
    NavItem(id: 'chat', icon: Icons.forum_rounded, label: 'Chat'),
    NavItem(id: 'tasks', icon: Icons.check_box_rounded, label: 'Tasks'),
    NavItem(id: 'calendar', icon: Icons.calendar_month_rounded, label: 'Calendar'),
    NavItem(id: 'photos', icon: Icons.grid_view_rounded, label: 'Album'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      color: AppColors.g50,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.g200),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tabs.map((tab) {
              final isActive = activeTab == tab.id;
              final color = isActive ? AppColors.blue : AppColors.g400;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChange(tab.id),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.blueL : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon, size: 23, color: color),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w900 : FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
