import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_localizations.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
import 'settings_detail_screens.dart';

class SettingItem {
  final IconData icon;
  final String labelKey;
  final Color color;

  SettingItem({
    required this.icon,
    required this.labelKey,
    required this.color,
  });
}

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String languageCode) onChangeLanguage;
  final Locale currentLocale;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.onChangeLanguage,
    required this.currentLocale,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedLanguageCode;
  late final AuthProvider _authProvider;

  late final List<SettingItem> settingsItems = [
    SettingItem(
      icon: Icons.person_rounded,
      labelKey: 'profileSettings',
      color: AppColors.blue,
    ),
    SettingItem(
      icon: Icons.notifications_rounded,
      labelKey: 'notifications',
      color: AppColors.orange,
    ),
    SettingItem(
      icon: Icons.shield_rounded,
      labelKey: 'privacySecurity',
      color: AppColors.green,
    ),
    SettingItem(
      icon: Icons.language_rounded,
      labelKey: 'languageRegion',
      color: AppColors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authProvider = Get.isRegistered<AuthProvider>()
        ? Get.find<AuthProvider>()
        : Get.put(AuthProvider(), permanent: true);
    selectedLanguageCode = widget.currentLocale.languageCode;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocale.languageCode != widget.currentLocale.languageCode) {
      selectedLanguageCode = widget.currentLocale.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.g50,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 48, 16, 0),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            decoration: BoxDecoration(
              color: AppColors.dashboardPurple,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.blue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  t.translate('settings'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Araboto',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ...settingsItems.map((item) {
                  return _buildSettingTile(
                    icon: item.icon,
                    label: t.translate(item.labelKey),
                    color: item.color,
                    onTap: () => _openSettingsItem(item.labelKey),
                  );
                }),

                _buildSettingTile(
                  icon: Icons.logout_rounded,
                  label: t.translate('logout'),
                  color: AppColors.red,
                  onTap: _logout,
                ),

                const SizedBox(height: 32),

                Text(
                  t.translate('quickSettings').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.g500,
                    letterSpacing: 0.5,
                    fontFamily: 'Araboto',
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.translate('language'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.g500,
                          fontFamily: 'Araboto',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.g50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: selectedLanguageCode,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.g500,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(
                                'English',
                                style: TextStyle(fontFamily: 'Araboto'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(
                                'العربية',
                                style: TextStyle(fontFamily: 'Araboto'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'cn',
                              child: Text(
                                '中文',
                                style: TextStyle(fontFamily: 'Araboto'),
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue == null) return;

                            setState(() {
                              selectedLanguageCode = newValue;
                            });

                            widget.onChangeLanguage(newValue);
                          },
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
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.g900,
                      fontFamily: 'Araboto',
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.g500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authProvider.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  void _openSettingsItem(String labelKey) {
    switch (labelKey) {
      case 'profileSettings':
        Get.to(() => const ProfileSettingsScreen());
        return;
      case 'notifications':
        Get.to(() => const NotificationSettingsScreen());
        return;
      case 'privacySecurity':
        Get.to(() => const PrivacySecurityScreen());
        return;
      case 'languageRegion':
        Get.to(
          () => LanguageRegionScreen(
            selectedLanguageCode: selectedLanguageCode,
            onChangeLanguage: (code) {
              setState(() => selectedLanguageCode = code);
              widget.onChangeLanguage(code);
            },
          ),
        );
        return;
    }
  }
}
