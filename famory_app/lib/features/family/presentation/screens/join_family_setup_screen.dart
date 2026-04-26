import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/family_service.dart';

class JoinFamilySetupScreen extends StatefulWidget {
  const JoinFamilySetupScreen({super.key});

  @override
  State<JoinFamilySetupScreen> createState() => _JoinFamilySetupScreenState();
}

class _JoinFamilySetupScreenState extends State<JoinFamilySetupScreen> {
  final _roleCtrl = TextEditingController();

  @override
  void dispose() {
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final args = (Get.arguments as Map?) ?? {};
    final inviteCode = (args['inviteCode'] ?? args['familyCode'])?.toString() ?? '';
    final role = _roleCtrl.text.trim().isEmpty ? 'Member' : _roleCtrl.text.trim();

    try {
      if (args['alreadyJoined'] == true) {
        await FamilyService().updateCurrentUserFamilyProfile(
          memberName: _currentUserName(),
          role: role,
        );
      } else {
        await FamilyService().joinFamily(
          inviteCode: inviteCode,
          memberName: _currentUserName(),
          role: role,
        );
      }
      Get.offAllNamed(AppRoutes.home);
    } catch (error) {
      Get.snackbar(
        'Join family failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _currentUserName() {
    if (!Get.isRegistered<AuthProvider>()) {
      return 'You';
    }

    final name = Get.find<AuthProvider>().currentUser.value?.name.trim();
    return name == null || name.isEmpty ? 'You' : name;
  }

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final familyName = args['familyName']?.toString() ?? 'Parker Family';

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text('Welcome to $familyName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g900)),
                          const SizedBox(height: 4),
                          const Text('Answer these questions', style: TextStyle(fontSize: 12, color: AppColors.g500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.g200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.blueL,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.extension_rounded, color: AppColors.blueD, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Your role in Family (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.g700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _roleCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Ex: Tech Support',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _finish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Finish'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _finish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Skip'),
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
    final displayName = _currentUserName();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.dashboardPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _Avatar(),
              Spacer(),
              _TopIcon(icon: Icons.settings_rounded),
              SizedBox(width: 10),
              _TopIcon(icon: Icons.add_circle_outline_rounded),
            ],
          ),
          const SizedBox(height: 30),
          Text('Good Morning $displayName', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
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

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Color(0xFF95BBFF), size: 20),
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
