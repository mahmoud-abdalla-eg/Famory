import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/family_service.dart';
import '../../data/services/invite_service.dart';

class CreateFamilyInviteScreen extends StatelessWidget {
  const CreateFamilyInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final family = FamilyService();
    final args = (Get.arguments as Map?) ?? {};
    final familyName = (args['familyName'] as String?) ?? family.familyName ?? 'Chen Family';
    final inviteCode = family.familyCode ?? InviteService().createInviteCode(familyName);

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
                          Text('Invite Your Family Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g900)),
                          SizedBox(height: 4),
                          Text('Quickly Share Family QR Code', style: TextStyle(fontSize: 12, color: AppColors.g500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InviteCard(
                      icon: Icons.qr_code_rounded,
                      iconColor: const Color(0xFFFF8C42),
                      iconBg: const Color(0xFFFFE6D5),
                      title: 'QR Code / Code',
                      subtitle: 'show the QR code to be scanned',
                      buttonLabel: 'Show',
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: inviteCode));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invite code copied: $inviteCode')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _InviteCard(
                      icon: Icons.image_outlined,
                      iconColor: const Color(0xFF4CB4EC),
                      iconBg: const Color(0xFFEAF6FC),
                      title: 'Save to Gallery',
                      subtitle: 'Save QR Code to send to invite family members',
                      buttonLabel: 'Save',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invite image will be generated later.')),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          family.markInviteLater();
                          Get.offAllNamed(AppRoutes.home);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Skip Add Later'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          family.markInviteLater();
                          Get.offAllNamed(AppRoutes.home);
                        },
                        child: const Text('Invite Later'),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF6E40E7),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              _Avatar(),
              Spacer(),
              _TopIcon(icon: Icons.settings_rounded),
              SizedBox(width: 10),
              _TopIcon(icon: Icons.add_circle_outline_rounded),
            ],
          ),
          SizedBox(height: 30),
          Text('Good Morning {Name}', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
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

class _InviteCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _InviteCard({
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 104,
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
