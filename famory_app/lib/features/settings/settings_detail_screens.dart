import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../family/data/services/family_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  static const String imagePathKey = 'profile_image_path';

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _imagePicker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.isRegistered<AuthProvider>() ? Get.find<AuthProvider>() : null;
    final user = authProvider?.currentUser.value;
    final family = FamilyService();
    final displayName = user?.name.trim().isNotEmpty == true ? user!.name : 'User';
    final email = user?.email.trim().isNotEmpty == true ? user!.email : 'No email saved';

    return _SettingsDetailScaffold(
      title: 'Profile',
      subtitle: 'Your account and family identity.',
      icon: Icons.person_rounded,
      children: [
        _ProfileHero(
          name: displayName,
          email: email,
          imagePath: _imagePath,
          onAddImage: _openImageSourceSheet,
          onRemoveImage: _imagePath == null ? null : _removeProfileImage,
        ),
        const SizedBox(height: 14),
        _InfoCard(
          title: 'Account Details',
          rows: [
            _InfoRow(label: 'Full name', value: displayName),
            _InfoRow(label: 'Email', value: email),
            _InfoRow(label: 'Role', value: user?.role ?? 'user'),
          ],
        ),
        const SizedBox(height: 14),
        _InfoCard(
          title: 'Family Details',
          rows: [
            _InfoRow(label: 'Family name', value: family.familyName ?? 'No family yet'),
            _InfoRow(label: 'Invite code', value: family.familyCode ?? 'Create or join a family'),
            _InfoRow(label: 'Members', value: family.members.length.toString()),
          ],
        ),
      ],
    );
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    final authProvider = Get.isRegistered<AuthProvider>() ? Get.find<AuthProvider>() : null;
    final backendPhoto = authProvider?.currentUser.value?.profilePhoto;
    final imagePath = backendPhoto?.trim().isNotEmpty == true
        ? backendPhoto
        : prefs.getString(ProfileSettingsScreen.imagePathKey);
    setState(() => _imagePath = imagePath?.trim().isEmpty == true ? null : imagePath);
  }

  Future<void> _openImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.g300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                _ImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Photos',
                  subtitle: 'Choose from your photo library',
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
                _ImageSourceOption(
                  icon: Icons.photo_camera_rounded,
                  title: 'Take picture',
                  subtitle: 'Open the camera',
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final image = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (image == null) {
      return;
    }

    final photoPath = await _saveProfileImageToBackend(File(image.path));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ProfileSettingsScreen.imagePathKey, photoPath);
    if (mounted) {
      setState(() => _imagePath = photoPath);
    }
  }

  Future<String> _saveProfileImageToBackend(File imageFile) async {
    if (!Get.isRegistered<AuthProvider>()) {
      return imageFile.path;
    }

    try {
      final updatedUser = await Get.find<AuthProvider>().updateProfilePhoto(imageFile);
      final backendPhoto = updatedUser.profilePhoto?.trim();
      if (backendPhoto != null && backendPhoto.isNotEmpty) {
        return backendPhoto;
      }
    } catch (error) {
      Get.snackbar(
        'Photo saved locally',
        'Could not upload profile photo: ${error.toString().replaceFirst('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return imageFile.path;
  }

  Future<void> _removeProfileImage() async {
    final shouldDelete = await _confirmRemoveProfileImage();
    if (!shouldDelete) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ProfileSettingsScreen.imagePathKey);
    if (Get.isRegistered<AuthProvider>()) {
      try {
        await Get.find<AuthProvider>().removeProfilePhoto();
      } catch (error) {
        Get.snackbar(
          'Photo removed locally',
          'Could not remove profile photo from backend: ${error.toString().replaceFirst('Exception: ', '')}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    if (mounted) {
      setState(() => _imagePath = null);
    }
  }

  Future<bool> _confirmRemoveProfileImage() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete profile photo?'),
          content: const Text('Are you sure you want to remove your profile photo?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result == true;
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool familyMessages = true;
  bool taskReminders = true;
  bool calendarAlerts = true;
  bool memories = false;

  @override
  Widget build(BuildContext context) {
    return _SettingsDetailScaffold(
      title: 'Notifications',
      subtitle: 'Choose what should get your attention.',
      icon: Icons.notifications_rounded,
      children: [
        _ToggleCard(
          title: 'Family messages',
          subtitle: 'New group chat messages and mentions.',
          value: familyMessages,
          onChanged: (value) => setState(() => familyMessages = value),
        ),
        _ToggleCard(
          title: 'Task reminders',
          subtitle: 'Chores, assignments, and due-date nudges.',
          value: taskReminders,
          onChanged: (value) => setState(() => taskReminders = value),
        ),
        _ToggleCard(
          title: 'Calendar alerts',
          subtitle: 'Events, birthdays, and shared plans.',
          value: calendarAlerts,
          onChanged: (value) => setState(() => calendarAlerts = value),
        ),
        _ToggleCard(
          title: 'Memory prompts',
          subtitle: 'Gentle reminders to add photos and moments.',
          value: memories,
          onChanged: (value) => setState(() => memories = value),
        ),
      ],
    );
  }
}

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool privateProfile = true;
  bool requireInviteCode = true;
  bool familyActivity = true;

  @override
  Widget build(BuildContext context) {
    return _SettingsDetailScaffold(
      title: 'Privacy & Security',
      subtitle: 'Control visibility and family access.',
      icon: Icons.shield_rounded,
      children: [
        _ToggleCard(
          title: 'Private profile',
          subtitle: 'Only family members can see your profile details.',
          value: privateProfile,
          onChanged: (value) => setState(() => privateProfile = value),
        ),
        _ToggleCard(
          title: 'Require invite code',
          subtitle: 'People must use the family code to join.',
          value: requireInviteCode,
          onChanged: (value) => setState(() => requireInviteCode = value),
        ),
        _ToggleCard(
          title: 'Family activity visibility',
          subtitle: 'Show completed tasks and shared activity in the family feed.',
          value: familyActivity,
          onChanged: (value) => setState(() => familyActivity = value),
        ),
        const _SuggestionCard(
          title: 'Security suggestion',
          body: 'Add backend endpoints later to persist these settings per user and per family.',
        ),
      ],
    );
  }
}

class LanguageRegionScreen extends StatefulWidget {
  final String selectedLanguageCode;
  final void Function(String languageCode) onChangeLanguage;

  const LanguageRegionScreen({
    super.key,
    required this.selectedLanguageCode,
    required this.onChangeLanguage,
  });

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  late String selectedLanguageCode = widget.selectedLanguageCode;

  @override
  Widget build(BuildContext context) {
    return _SettingsDetailScaffold(
      title: 'Language & Region',
      subtitle: 'Pick the language used across the app.',
      icon: Icons.language_rounded,
      children: [
        _LanguageTile(
          label: 'English',
          code: 'en',
          selectedCode: selectedLanguageCode,
          onSelect: _selectLanguage,
        ),
        _LanguageTile(
          label: 'العربية',
          code: 'ar',
          selectedCode: selectedLanguageCode,
          onSelect: _selectLanguage,
        ),
        _LanguageTile(
          label: '中文',
          code: 'cn',
          selectedCode: selectedLanguageCode,
          onSelect: _selectLanguage,
        ),
        const SizedBox(height: 12),
        const _SuggestionCard(
          title: 'Region suggestion',
          body: 'Add timezone, date format, and first-day-of-week settings when calendar syncing is connected.',
        ),
      ],
    );
  }

  void _selectLanguage(String code) {
    setState(() => selectedLanguageCode = code);
    widget.onChangeLanguage(code);
  }
}

class _SettingsDetailScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const _SettingsDetailScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                color: AppColors.dashboardPurple,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _CircleIcon(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Get.back(),
                      ),
                      const Spacer(),
                      _CircleIcon(icon: icon),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.74)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.blue, size: 20),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String name;
  final String email;
  final String? imagePath;
  final VoidCallback onAddImage;
  final VoidCallback? onRemoveImage;

  const _ProfileHero({
    required this.name,
    required this.email,
    required this.imagePath,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                name: name,
                imagePath: imagePath,
                radius: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.g900)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 12, color: AppColors.g500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: Text(imagePath == null ? 'Add image' : 'Change image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (onRemoveImage != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onRemoveImage,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? imagePath;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.imagePath,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final image = _profileImage(imagePath);
    final initial = name.trim().isEmpty ? 'U' : name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: image == null
            ? const LinearGradient(
                colors: [Color(0xFFFFF1D8), Color(0xFF9BE7D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: image == null ? null : DecorationImage(image: image, fit: BoxFit.cover),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: image == null
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: AppColors.dashboardPurpleD,
                  fontSize: radius * 0.78,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : null,
    );
  }

  ImageProvider? _profileImage(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }

    final file = File(value);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }
}

class ProfileAvatarButton extends StatelessWidget {
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatarButton({
    super.key,
    required this.name,
    this.radius = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        Widget buildButton(String? backendPhoto) {
          final imagePath = backendPhoto?.trim().isNotEmpty == true
              ? backendPhoto
              : snapshot.data?.getString(ProfileSettingsScreen.imagePathKey);
          return GestureDetector(
            onTap: onTap ?? () => Get.to(() => const ProfileSettingsScreen()),
            behavior: HitTestBehavior.opaque,
            child: ProfileAvatar(
              name: name,
              imagePath: imagePath,
              radius: radius,
            ),
          );
        }

        if (!Get.isRegistered<AuthProvider>()) {
          return buildButton(null);
        }

        final authProvider = Get.find<AuthProvider>();
        return Obx(() => buildButton(authProvider.currentUser.value?.profilePhoto));
      },
    );
  }
}

class ProfileMemberAvatarButton extends StatelessWidget {
  final String name;

  const ProfileMemberAvatarButton({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        Widget buildButton(String? backendPhoto) {
          final imagePath = backendPhoto?.trim().isNotEmpty == true
              ? backendPhoto
              : snapshot.data?.getString(ProfileSettingsScreen.imagePathKey);
          return GestureDetector(
            onTap: () => Get.to(() => const ProfileSettingsScreen()),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                ProfileAvatar(
                  name: name,
                  imagePath: imagePath,
                  radius: 25,
                ),
                const SizedBox(height: 7),
                Text(name, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                ),
              ],
            ),
          );
        }

        if (!Get.isRegistered<AuthProvider>()) {
          return buildButton(null);
        }

        final authProvider = Get.find<AuthProvider>();
        return Obx(() => buildButton(authProvider.currentUser.value?.profilePhoto));
      },
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.purpleL,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.dashboardPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.g900)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.g500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.g400),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.g900)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g500, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.g800, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.g900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.g500, height: 1.35)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String code;
  final String selectedCode;
  final ValueChanged<String> onSelect;

  const _LanguageTile({
    required this.label,
    required this.code,
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = code == selectedCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        onTap: () => onSelect(code),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.g900)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
          color: isSelected ? AppColors.blue : AppColors.g400,
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String body;

  const _SuggestionCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueL,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.g900)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 12, color: AppColors.g600, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.g200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
