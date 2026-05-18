import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../family/data/models/family_member.dart';
import '../../../family/data/services/family_service.dart';
import 'chat_conversation_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  String? _currentUserId;

  FamilyService get _familyService => FamilyService();

  List<FamilyMember> get _directMembers {
    return _familyService.members
        .where((member) => member.id.isNotEmpty && member.id != _currentUserId)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() => _currentUserId = prefs.getString('user_id'));
  }

  @override
  Widget build(BuildContext context) {
    final directMembers = _directMembers;

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MessagesHeader(),
              const SizedBox(height: 14),
              _SearchSurface(
                membersCount: _familyService.members.length,
              ),
              const SizedBox(height: 16),
              _ChatShortcuts(
                familyName: _familyService.familyName,
                members: directMembers,
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Pinned'),
              const SizedBox(height: 10),
              _FamilyGroupCard(
                familyName: _familyService.familyName ?? 'Family Chat',
                memberCount: _familyService.members.length,
                onTap: () => Get.to(
                  () => ChatConversationScreen.family(
                    familyId: _familyService.familyId,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Direct Messages'),
              const SizedBox(height: 10),
              if (directMembers.isEmpty)
                const _NoDirectMessages()
              else
                _DirectMessagesCard(rows: _buildDirectMessageRows(directMembers)),
              const SizedBox(height: 20),
              const _SectionLabel('Assistant'),
              const SizedBox(height: 10),
              _AiAssistantCard(
                onTap: () => Get.to(
                  () => const ChatConversationScreen.ai(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDirectMessageRows(List<FamilyMember> members) {
    final rows = <Widget>[];
    for (var index = 0; index < members.length; index++) {
      final member = members[index];
      rows.add(
        _DirectMessageRow(
          initials: member.initials,
          name: member.name,
          message: member.isOnline ? 'Online now' : 'Tap to start a chat',
          time: member.isOnline ? 'Now' : '',
          unreadCount: 0,
          color: _memberColor(index + 1),
          onTap: () => Get.to(
            () => ChatConversationScreen.direct(
              name: member.name,
              initials: member.initials,
              color: _memberColor(index + 1),
              recipientId: member.id,
            ),
          ),
        ),
      );
    }

    return rows;
  }

  Color _memberColor(int index) {
    const colors = [
      AppColors.blue,
      AppColors.orange,
      AppColors.green,
      AppColors.teal,
      AppColors.purple,
    ];

    return colors[index % colors.length];
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  color: AppColors.g900,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Stay close to your family.',
                style: TextStyle(
                  color: AppColors.g500,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.edit_square, color: Colors.white, size: 19),
        ),
      ],
    );
  }
}

class _SearchSurface extends StatelessWidget {
  final int membersCount;

  const _SearchSurface({required this.membersCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.blueL,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.blue, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Search family messages',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.g400,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.greenL,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$membersCount online',
              style: const TextStyle(
                color: AppColors.greenD,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatShortcuts extends StatelessWidget {
  final String? familyName;
  final List<FamilyMember> members;

  const _ChatShortcuts({
    required this.familyName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const _NewGroupShortcut(),
          const SizedBox(width: 12),
          _ChatShortcut(
            label: _shortLabel(familyName ?? 'Family'),
            initials: 'F',
            color: AppColors.blue,
            selected: true,
          ),
          for (var index = 0; index < members.take(5).length; index++) ...[
            const SizedBox(width: 12),
            _ChatShortcut(
              label: _shortLabel(members[index].name),
              initials: members[index].initials,
              color: _shortcutColor(index + 1),
            ),
          ],
        ],
      ),
    );
  }

  String _shortLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Family';
    }

    return trimmed.split(RegExp(r'\s+')).first;
  }

  Color _shortcutColor(int index) {
    const colors = [
      AppColors.blue,
      AppColors.orange,
      AppColors.green,
      AppColors.teal,
      AppColors.purple,
    ];

    return colors[index % colors.length];
  }
}

class _NewGroupShortcut extends StatelessWidget {
  const _NewGroupShortcut();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 58,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            child: SizedBox(
              width: 54,
              height: 54,
              child: Icon(Icons.add_rounded, color: AppColors.blue, size: 25),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'New',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.g500,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatShortcut extends StatelessWidget {
  final String label;
  final String initials;
  final Color color;
  final bool selected;

  const _ChatShortcut({
    required this.label,
    required this.initials,
    required this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: selected ? AppColors.blueL : Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: selected ? AppColors.blue : AppColors.g200,
                width: 1.5,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.g700,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.g400,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _FamilyGroupCard extends StatelessWidget {
  final String familyName;
  final int memberCount;
  final VoidCallback onTap;

  const _FamilyGroupCard({
    required this.familyName,
    required this.memberCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(Icons.groups_2_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    familyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    memberCount > 0
                        ? '$memberCount ${memberCount == 1 ? 'member' : 'members'} connected'
                        : 'Send your first family message',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 17),
          ],
        ),
      ),
    );
  }
}

class _DirectMessagesCard extends StatelessWidget {
  final List<Widget> rows;

  const _DirectMessagesCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.g200),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index != rows.length - 1)
              const Divider(height: 1, indent: 74, endIndent: 14, color: AppColors.g100),
          ],
        ],
      ),
    );
  }
}

class _NoDirectMessages extends StatelessWidget {
  const _NoDirectMessages();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.g200),
      ),
      child: const Text(
        'Invite family members to start direct chats.',
        style: TextStyle(
          color: AppColors.g500,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DirectMessageRow extends StatelessWidget {
  final String initials;
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final Color color;
  final VoidCallback onTap;

  const _DirectMessageRow({
    required this.initials,
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: color,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.g900,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.g400,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _TimeAndBadge(time: time, unreadCount: unreadCount),
          ],
        ),
      ),
    );
  }
}

class _TimeAndBadge extends StatelessWidget {
  final String time;
  final int unreadCount;

  const _TimeAndBadge({required this.time, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: const TextStyle(
            color: AppColors.g400,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (unreadCount > 0)
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          )
        else
          const Icon(Icons.chevron_right_rounded, color: AppColors.g300, size: 22),
      ],
    );
  }
}

class _AiAssistantCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AiAssistantCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.g200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.g900,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Image.asset(
                  'assets/images/Famory_Ai_white_logo.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@famory AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.g900,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ask for tasks, plans, meals, and reminders',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.g400,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.blueL,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.blue, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
