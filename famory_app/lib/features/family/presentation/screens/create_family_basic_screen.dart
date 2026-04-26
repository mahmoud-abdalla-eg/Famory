import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CreateFamilyBasicScreen extends StatefulWidget {
  const CreateFamilyBasicScreen({super.key});

  @override
  State<CreateFamilyBasicScreen> createState() => _CreateFamilyBasicScreenState();
}

class _CreateFamilyBasicScreenState extends State<CreateFamilyBasicScreen> {
  final _nameCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  final _specialCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sloganCtrl.dispose();
    _specialCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final familyName = _nameCtrl.text.trim();
    if (familyName.length < 3 || familyName.length > 50) {
      Get.snackbar('Check family name', 'Family name must be between 3 and 50 characters.');
      return;
    }

    Get.toNamed(
      AppRoutes.familyCreateRole,
      arguments: {
        'familyName': familyName,
        'motto': _sloganCtrl.text.trim(),
        'specialDate': _specialCtrl.text.trim(),
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
                          Text('Create Your Family Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.g900)),
                          SizedBox(height: 4),
                          Text('Write Your Family Information', style: TextStyle(fontSize: 12, color: AppColors.g500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PhotoCard(
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _InputCard(
                      icon: Icons.home_rounded,
                      title: 'Family Name*',
                      controller: _nameCtrl,
                      hint: 'Ex: Chen Family',
                    ),
                    const SizedBox(height: 12),
                    _InputCard(
                      icon: Icons.favorite_rounded,
                      title: 'Family Slogan (optional)',
                      controller: _sloganCtrl,
                      hint: 'Ex: Manage the household with...',
                    ),
                    const SizedBox(height: 12),
                    _InputCard(
                      icon: Icons.event_rounded,
                      title: 'Special Date (optional)',
                      controller: _specialCtrl,
                      hint: 'Name: Wedding Anniversary',
                      secondHint: 'Date: 1989/6/15',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Create Family'),
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

class _PhotoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PhotoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.blueL, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.image_rounded, color: AppColors.blueD),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Group Photo (optional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.g700),
            ),
          ),
          const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.g700)),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.g200, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;
  final String hint;
  final String? secondHint;

  const _InputCard({
    required this.icon,
    required this.title,
    required this.controller,
    required this.hint,
    this.secondHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.blueL, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.blueD, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.g700)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                  ),
                ),
                if (secondHint != null) ...[
                  const SizedBox(height: 10),
                  Text(secondHint!, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
