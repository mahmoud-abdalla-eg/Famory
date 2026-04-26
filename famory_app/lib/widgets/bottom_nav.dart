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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tabs.map((tab) {
              final isActive = activeTab == tab.id;
              final color = isActive ? AppColors.blue : AppColors.g700;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChange(tab.id),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon, size: 28, color: color),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w900 : FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: isActive ? 24 : 0,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(99),
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
