import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/settings_detail_screens.dart';

class EmptyDashboardScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const EmptyDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(
                name: _currentUserName(),
                subtitle: 'Welcome! Let\'s get your family setup.',
                showAdd: true,
                onSettingsTap: () => onNavigate('settings'),
                onProfileTap: () => Get.to(() => const ProfileSettingsScreen()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Family Setup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.g700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ActionCard(
                      icon: Icons.groups_rounded,
                      iconColor: const Color(0xFFFF8C42),
                      iconBg: const Color(0xFFFFE6D5),
                      title: 'Create a Family',
                      subtitle: 'Create your family and invite members',
                      buttonLabel: 'Create',
                      onTap: () => Get.toNamed(AppRoutes.familyCreate),
                    ),
                    const SizedBox(height: 18),
                    _ActionCard(
                      icon: Icons.group_rounded,
                      iconColor: const Color(0xFF4CB4EC),
                      iconBg: const Color(0xFFEAF6FC),
                      title: 'Join a Family',
                      subtitle: 'Join a family using QR code or code',
                      buttonLabel: 'Open',
                      onTap: () => Get.toNamed(AppRoutes.familyJoin),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.g500,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: 'Need Help? '),
                            TextSpan(
                              text: 'Ask a family member',
                              style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _currentUserName() {
    if (!Get.isRegistered<AuthProvider>()) {
      return 'Name';
    }

    final name = Get.find<AuthProvider>().currentUser.value?.name.trim();
    return name == null || name.isEmpty ? 'Name' : name;
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool showAdd;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;

  const _Header({
    required this.name,
    required this.subtitle,
    required this.showAdd,
    required this.onSettingsTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.dashboardPurple,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatarButton(name: name, onTap: onProfileTap),
              const Spacer(),
              _TopIcon(icon: Icons.settings_rounded, onTap: onSettingsTap),
              if (showAdd) ...[
                const SizedBox(width: 8),
                const _TopIcon(icon: Icons.add_circle_outline_rounded),
              ],
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  'Good Morning $name',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.g900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.g500, height: 1.3),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 112,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
