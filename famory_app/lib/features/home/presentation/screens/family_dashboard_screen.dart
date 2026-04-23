import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../family/data/models/family_member.dart';
import '../../../family/data/services/family_service.dart';

class FamilyDashboardScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const FamilyDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final family = FamilyService();
    final members = family.members;
    final displayName = family.ownerName ?? 'Name';

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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        _StatChip(value: '5', label: 'Open Tasks', color: Color(0xFF6F43E5)),
                        SizedBox(width: 8),
                        _StatChip(value: '2', label: 'Events Today', color: Color(0xFF16B39C)),
                        SizedBox(width: 8),
                        _StatChip(value: '12', label: 'Messages', color: Color(0xFF1B76FD)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your Family Members',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.g700),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 68,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: members.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          if (index == members.length) {
                            return const _InviteMember();
                          }
                          return _MemberPill(member: members[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.g700),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.6,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _QuickActionCard(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Add Tasks',
                          subtitle: 'Family Chores',
                          onTap: () => onNavigate('tasks'),
                        ),
                        _QuickActionCard(
                          icon: Icons.calendar_month_outlined,
                          title: 'Add Event',
                          subtitle: 'Family Calendar',
                          onTap: () => onNavigate('calendar'),
                        ),
                        _QuickActionCard(
                          icon: Icons.photo_library_outlined,
                          title: 'Add Memory',
                          subtitle: 'Family Album',
                          onTap: () => onNavigate('photos'),
                        ),
                        _QuickActionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Family Chat',
                          subtitle: '12 unread',
                          onTap: () => onNavigate('chat'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'On This Day',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.g700),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.g200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1501973801540-537f08ccae7b?w=900&h=500&fit=crop&crop=center',
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Text(
                                '3 years ago today',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.g800),
                              ),
                              Spacer(),
                              Text(
                                'Open Album',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blue),
                              ),
                            ],
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
}

class _Header extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool showAdd;

  const _Header({
    required this.name,
    required this.subtitle,
    required this.showAdd,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Avatar(),
              const Spacer(),
              const _TopIcon(icon: Icons.settings_rounded),
              if (showAdd) ...[
                const SizedBox(width: 10),
                const _TopIcon(icon: Icons.add_circle_outline_rounded),
              ],
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Text(
                  'Good Morning {$name}',
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

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  final FamilyMember member;

  const _MemberPill({required this.member});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFF6E40E7),
          child: Text(member.initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 6),
        Text(member.name.split(' ').first, style: const TextStyle(fontSize: 10, color: AppColors.g700)),
      ],
    );
  }
}

class _InviteMember extends StatelessWidget {
  const _InviteMember();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.g200,
          child: Icon(Icons.add, size: 16, color: AppColors.g600),
        ),
        SizedBox(height: 6),
        Text('Invite', style: TextStyle(fontSize: 10, color: AppColors.g700)),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.g200),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.g50,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: AppColors.g800),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.g800)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.g500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
