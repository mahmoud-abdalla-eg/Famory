import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/family_service.dart';

class CreateFamilyRoleScreen extends StatefulWidget {
  const CreateFamilyRoleScreen({super.key});

  @override
  State<CreateFamilyRoleScreen> createState() => _CreateFamilyRoleScreenState();
}

class _CreateFamilyRoleScreenState extends State<CreateFamilyRoleScreen> {
  String _role = 'Parent';

  void _continue() {
    final args = (Get.arguments as Map?) ?? {};
    final familyName = (args['familyName'] as String?) ?? 'The Famory Family';
    final homeCity = (args['homeCity'] as String?) ?? '';
    final motto = (args['motto'] as String?) ?? '';

    FamilyService().createFamily(
      name: familyName,
      owner: 'You',
      role: _role,
    );
    Get.toNamed(
      AppRoutes.familyInvite,
      arguments: {
        'familyName': familyName,
        'homeCity': homeCity,
        'motto': motto,
        'role': _role,
      },
    );
  }

  void _skipStep() {
    final args = (Get.arguments as Map?) ?? {};
    final familyName = (args['familyName'] as String?) ?? 'The Famory Family';
    final homeCity = (args['homeCity'] as String?) ?? '';
    final motto = (args['motto'] as String?) ?? '';

    FamilyService().createFamily(
      name: familyName,
      owner: 'You',
      role: 'Parent',
    );
    Get.toNamed(
      AppRoutes.familyInvite,
      arguments: {
        'familyName': familyName,
        'homeCity': homeCity,
        'motto': motto,
        'role': 'Parent',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final familyName = (args['familyName'] as String?) ?? 'The Famory Family';

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(familyName: familyName),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Who is this family for?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.g500)),
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
                          const Text('Choose your role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.g900)),
                          const SizedBox(height: 8),
                          const Text('This helps us suggest the right permissions and welcome message.', style: TextStyle(fontSize: 12, color: AppColors.g500, height: 1.4)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _RoleChip(label: 'Parent', selected: _role == 'Parent', onTap: () => setState(() => _role = 'Parent')),
                              _RoleChip(label: 'Guardian', selected: _role == 'Guardian', onTap: () => setState(() => _role = 'Guardian')),
                              _RoleChip(label: 'Child', selected: _role == 'Child', onTap: () => setState(() => _role = 'Child')),
                              _RoleChip(label: 'Other', selected: _role == 'Other', onTap: () => setState(() => _role = 'Other')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _skipStep,
                        child: const Text('Skip this step'),
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
  final String familyName;

  const _Header({required this.familyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6E4BFF), Color(0xFF3E36D1)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
              ),
              const Spacer(),
              const _MiniCircle(icon: Icons.notifications_none_rounded),
              const SizedBox(width: 8),
              const _MiniCircle(icon: Icons.settings_outlined),
            ],
          ),
          const SizedBox(height: 22),
          Text('Create $familyName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Pick the role that best describes you before we add invites.', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.84), height: 1.4)),
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

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.blueL,
      labelStyle: TextStyle(
        color: selected ? AppColors.blueD : AppColors.g600,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? AppColors.blue : AppColors.g200),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}
