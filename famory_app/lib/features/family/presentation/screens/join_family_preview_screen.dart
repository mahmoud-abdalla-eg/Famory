import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class JoinFamilyPreviewScreen extends StatelessWidget {
  const JoinFamilyPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final familyName = (args['familyName'] as String?) ?? 'The Parker Family';
    final familyCode = (args['familyCode'] as String?) ?? 'No code loaded';

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Family Preview',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.g500),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.g200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.blueL,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.groups_rounded, color: AppColors.blueD, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(familyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.g900)),
                                    const SizedBox(height: 4),
                                    const Text('4 members • Active family space', style: TextStyle(fontSize: 12, color: AppColors.g500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MiniPill(label: 'Tasks', color: AppColors.blueL, textColor: AppColors.blueD),
                              _MiniPill(label: 'Chat', color: AppColors.orangeL, textColor: AppColors.orange),
                              _MiniPill(label: 'Calendar', color: AppColors.greenL, textColor: AppColors.greenD),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.g50,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.g200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Family Code', style: TextStyle(fontSize: 12, color: AppColors.g500, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(familyCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g900)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.familyJoinSetup, arguments: args),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Looks Right, Continue'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: Get.back,
                        child: const Text('Back to join options'),
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.dashboardPurple, AppColors.dashboardPurpleD],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _MiniCircle(icon: Icons.qr_code_scanner_rounded),
              Spacer(),
              _MiniCircle(icon: Icons.notifications_none_rounded),
              SizedBox(width: 8),
              _MiniCircle(icon: Icons.settings_outlined),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Join a Family Preview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Make sure the family looks right before we move to the setup questions.', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.84), height: 1.4)),
        ],
      ),
    );
  }
}

class _MiniCircle extends StatelessWidget {
  final IconData icon;

  const _MiniCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MiniPill({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
