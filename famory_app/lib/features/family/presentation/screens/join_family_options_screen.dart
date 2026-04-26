import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/family_service.dart';

class JoinFamilyOptionsScreen extends StatefulWidget {
  const JoinFamilyOptionsScreen({super.key});

  @override
  State<JoinFamilyOptionsScreen> createState() => _JoinFamilyOptionsScreenState();
}

class _JoinFamilyOptionsScreenState extends State<JoinFamilyOptionsScreen> {
  final _codeCtrl = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _openSetup({String? inviteCode}) async {
    final code = (inviteCode ?? _codeCtrl.text).trim().toUpperCase();
    if (code.length < 4 || code.length > 32) {
      Get.snackbar('Invalid code', 'Enter a family invite code between 4 and 32 characters.');
      return;
    }

    setState(() => _isChecking = true);
    try {
      await FamilyService().joinFamily(
        inviteCode: code,
        memberName: _currentUserName(),
        role: 'Member',
      );

      if (!mounted) {
        return;
      }

      Get.toNamed(
        AppRoutes.familyJoinSetup,
        arguments: {
          'familyName': FamilyService().familyName ?? 'Family invite',
          'inviteCode': code,
          'alreadyJoined': true,
        },
      );
    } catch (error) {
      Get.snackbar(
        'Invalid family code',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
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
    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          Text('Join Your Family Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g900)),
                          SizedBox(height: 4),
                          Text('Quickly Scan Family QR Code', style: TextStyle(fontSize: 12, color: AppColors.g500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _JoinCard(
                      icon: Icons.qr_code_rounded,
                      iconColor: const Color(0xFFFF8C42),
                      iconBg: const Color(0xFFFFE6D5),
                      title: 'Scan QR Code',
                      subtitle: 'Scan the QR code with your camera',
                      buttonLabel: _isChecking ? 'Checking' : 'Scan',
                      onTap: _isChecking
                          ? null
                          : () {
                              _openSetup(inviteCode: _codeCtrl.text.trim());
                            },
                    ),
                    const SizedBox(height: 12),
                    _JoinCard(
                      icon: Icons.image_outlined,
                      iconColor: const Color(0xFF4CB4EC),
                      iconBg: const Color(0xFFEAF6FC),
                      title: 'Scan from Gallery',
                      subtitle: 'Scan the QR code from your gallery',
                      buttonLabel: _isChecking ? 'Checking' : 'Open',
                      onTap: _isChecking
                          ? null
                          : () {
                              _openSetup(inviteCode: _codeCtrl.text.trim());
                            },
                    ),
                    const SizedBox(height: 12),
                    _JoinCard(
                      icon: Icons.numbers_rounded,
                      iconColor: const Color(0xFFFF8C42),
                      iconBg: const Color(0xFFFFE6D5),
                      title: 'Enter Family Code',
                      subtitle: 'Ask your family members for Family Code',
                      buttonLabel: 'Enter',
                      trailing: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeCtrl,
                                decoration: const InputDecoration(hintText: ''),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 54,
                              height: 34,
                              child: ElevatedButton(
                                onPressed: _isChecking
                                    ? null
                                    : () {
                                        _openSetup();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: _isChecking
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Enter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: _isChecking
                          ? null
                          : () {
                              _openSetup();
                            },
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

class _JoinCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _JoinCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    this.trailing,
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
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.g900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.g500, height: 1.3)),
                if (trailing != null) ...[
                  const SizedBox(height: 10),
                  trailing!,
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 105,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(buttonLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
