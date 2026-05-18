import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../family/data/models/family_member.dart';
import '../../../family/data/services/family_service.dart';
import '../../../settings/settings_detail_screens.dart';

class FamilyDashboardScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const FamilyDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final family = FamilyService();
    final members = family.members;
    final displayName = _firstName(_currentUserName() ?? family.ownerName ?? 'Name');
    final familyName = family.familyName ?? 'Your Family';
    final currentUserId = _currentUserId();

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(
                name: displayName,
                subtitle: 'Here\'s what\'s happening with your family.',
                showAdd: true,
                onSettingsTap: () => onNavigate('settings'),
                onProfileTap: () => Get.to(() => const ProfileSettingsScreen()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$familyName Members',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: AppColors.g400),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: members.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 18),
                        itemBuilder: (context, index) {
                          if (index == members.length) {
                            return _InviteMember(
                              onTap: () => Get.toNamed(AppRoutes.familyInvite),
                            );
                          }
                          return _MemberPill(
                            member: members[index],
                            isCurrentUser: members[index].id == currentUserId,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: AppColors.g400),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.0,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _QuickActionCard(
                          icon: Icons.add_task_rounded,
                          title: 'Add Tasks',
                          subtitle: 'Family Chores',
                          iconColor: AppColors.blue,
                          iconBg: AppColors.blueL,
                          onTap: () => onNavigate('tasks'),
                        ),
                        _QuickActionCard(
                          icon: Icons.edit_calendar_outlined,
                          title: 'Add Event',
                          subtitle: 'Family Calendar',
                          iconColor: AppColors.greenD,
                          iconBg: AppColors.greenL,
                          onTap: () => onNavigate('calendar'),
                        ),
                        _QuickActionCard(
                          icon: Icons.add_photo_alternate_outlined,
                          title: 'Add Memory',
                          subtitle: 'Family Album',
                          iconColor: AppColors.teal,
                          iconBg: AppColors.tealL,
                          onTap: () => onNavigate('photos'),
                        ),
                        _QuickActionCard(
                          icon: Icons.forum_outlined,
                          title: 'Family Chat',
                          subtitle: '12 unread',
                          iconColor: AppColors.orange,
                          iconBg: AppColors.orangeL,
                          onTap: () => onNavigate('chat'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'On This Day',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: AppColors.g400),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.g200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=900&h=420&fit=crop&crop=center',
                              height: 138,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Text(
                                  '3 years ago today',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => onNavigate('photos'),
                                  behavior: HitTestBehavior.opaque,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    child: Text(
                                      'Open Album',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  String? _currentUserName() {
    if (!Get.isRegistered<AuthProvider>()) {
      return null;
    }

    final name = Get.find<AuthProvider>().currentUser.value?.name.trim();
    if (name == null ||
        name.isEmpty ||
        name.contains('@') ||
        name.toLowerCase() == 'user') {
      return null;
    }

    return name;
  }

  String? _currentUserId() {
    if (!Get.isRegistered<AuthProvider>()) {
      return null;
    }

    return Get.find<AuthProvider>().currentUser.value?.id;
  }

  String _firstName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty || parts.first.contains('@')) {
      return 'Name';
    }

    return parts.first;
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
      decoration: const BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatarButton(name: name, onTap: onProfileTap),
              const Spacer(),
              const _TopIcon(icon: Icons.notifications_rounded),
              const SizedBox(width: 10),
              _TopIcon(icon: Icons.settings_rounded, onTap: onSettingsTap),
              if (showAdd) ...[
                const SizedBox(width: 10),
                const _TopIcon(icon: Icons.add_circle_outline_rounded),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'Good Morning $name',
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.72), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              _StatChip(
                value: '5',
                label: 'Open Tasks',
                color: Color(0xFF7C42E8),
                progressColor: Color(0xFFE85CF5),
                icon: Icons.assignment_outlined,
              ),
              SizedBox(width: 12),
              _StatChip(
                value: '2',
                label: 'Events Today',
                color: AppColors.teal,
                progressColor: Color(0xFFFFA069),
                icon: Icons.calendar_month_rounded,
              ),
              SizedBox(width: 12),
              _StatChip(
                value: '12',
                label: 'Messages',
                color: AppColors.blue,
                progressColor: Color(0xFF80DBFF),
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ],
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

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color progressColor;
  final IconData icon;

  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
    required this.progressColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -9,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 1,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            Positioned(
              left: 30,
              right: 0,
              top: 4,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 3,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.95), fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  final FamilyMember member;
  final bool isCurrentUser;

  const _MemberPill({
    required this.member,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = _memberDisplayName(member.name);
    if (isCurrentUser) {
      return ProfileMemberAvatarButton(name: name);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: _memberColor(name),
          child: Text(
            _memberInitials(name),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 7),
        Text(name, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        _OnlineDot(isOnline: member.isOnline),
      ],
    );
  }

  String _memberDisplayName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty && !part.contains('@'))
        .toList();
    if (parts.isEmpty) {
      return 'Member';
    }

    return parts.take(2).join(' ');
  }

  String _memberInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'M';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _memberColor(String name) {
    const colors = [
      AppColors.blue,
      Color(0xFFEF4444),
      AppColors.purple,
      Color(0xFFEC4899),
      AppColors.teal,
      AppColors.orange,
    ];
    final index = name.codeUnits.fold<int>(0, (sum, code) => sum + code) % colors.length;
    return colors[index];
  }
}

class _InviteMember extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteMember({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Column(
        children: [
          CustomPaint(
            painter: _DashedCirclePainter(color: AppColors.g300),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: Icon(Icons.add, size: 26, color: AppColors.g500),
              ),
            ),
          ),
          SizedBox(height: 7),
          Text('Invite', style: TextStyle(fontSize: 12, color: AppColors.g500, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  final bool isOnline;

  const _OnlineDot({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.teal : AppColors.g500,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const dashCount = 16;
    final rect = Offset.zero & size;
    for (var i = 0; i < dashCount; i++) {
      final start = (i / dashCount) * 6.283185307179586;
      canvas.drawArc(rect.deflate(1), start, 0.22, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.g200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.g500, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
