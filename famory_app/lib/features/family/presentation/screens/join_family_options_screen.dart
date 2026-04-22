import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class JoinFamilyOptionsScreen extends StatefulWidget {
  const JoinFamilyOptionsScreen({super.key});

  @override
  State<JoinFamilyOptionsScreen> createState() => _JoinFamilyOptionsScreenState();
}

class _JoinFamilyOptionsScreenState extends State<JoinFamilyOptionsScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _openSetup() {
    Get.toNamed(
      AppRoutes.familyJoinSetup,
      arguments: {
        'familyName': 'Parker Family',
      },
    );
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
                      buttonLabel: 'Scan',
                      onTap: _openSetup,
                    ),
                    const SizedBox(height: 12),
                    _JoinCard(
                      icon: Icons.image_outlined,
                      iconColor: const Color(0xFF4CB4EC),
                      iconBg: const Color(0xFFEAF6FC),
                      title: 'Scan from Gallery',
                      subtitle: 'Scan the QR code from your gallery',
                      buttonLabel: 'Open',
                      onTap: _openSetup,
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
                                onPressed: _openSetup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text('Enter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: _openSetup,
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

class _JoinCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
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
