import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyDashboardScreen extends StatelessWidget {
  const EmptyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _Header(
                name: 'Name',
                subtitle: 'Welcome! Let\'s get your family setup.',
                avatarInitial: 'N',
                showAdd: true,
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
}

class _Header extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatarInitial;
  final bool showAdd;

  const _Header({
    required this.name,
    required this.subtitle,
    required this.avatarInitial,
    required this.showAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF6E40E7),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(avatarInitial: avatarInitial),
              const Spacer(),
              const _TopIcon(icon: Icons.settings_rounded),
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
                  'Good Morning {$name}',
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

class _Avatar extends StatelessWidget {
  final String avatarInitial;

  const _Avatar({required this.avatarInitial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          avatarInitial,
          style: const TextStyle(
            color: Color(0xFF91B9FF),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;

  const _TopIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white, size: 22);
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
                        backgroundColor: const Color(0xFF0D6EFD),
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
