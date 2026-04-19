import 'package:flutter/material.dart';
import '../../../../app_localizations.dart';
import '../../../../theme.dart';
import '../../../../widgets/custom_avatar.dart';
import '../../../../widgets/feature_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomAvatar(
                    name: 'Sarah Miller',
                    size: AvatarSize.large,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => onNavigate('settings'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.deepBlue,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.softBlueBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.notifications_rounded,
                              color: AppColors.deepBlue,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                t.translate('dashboardWelcomeTitle'),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                t.translate('dashboardWelcomeSubtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              FeatureCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3EB6EC), Color(0xFF2E9ECE)],
                ),
                onTap: () => onNavigate('chat'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.translate('familyChat'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Araboto',
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Araboto',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.translate('familyChatPreview'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Araboto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.translate('minutesAgo2'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.7),
                        fontSize: 12,
                        fontFamily: 'Araboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              FeatureCard(
                color: Colors.white,
                onTap: () => onNavigate('tasks'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.translate('tasks'),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Araboto',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.translate('tasksDoneSummary'),
                            style: const TextStyle(
                              color: AppColors.successGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Araboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0, end: 0.43),
                        builder: (context, double value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.bgMain,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.successGreen,
                            ),
                            minHeight: 8,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.translate('nextTaskToday'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Araboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              FeatureCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE6D5), Color(0xFFFF8C42)],
                ),
                onTap: () => onNavigate('calendar'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.translate('upcomingEvents'),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Araboto',
                          ),
                        ),
                        Text(
                          t.translate('today'),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontSize: 12,
                            fontFamily: 'Araboto',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t.translate('monthApr'),
                                style: const TextStyle(
                                  color: AppColors.deepBlue,
                                  fontSize: 10,
                                  fontFamily: 'Araboto',
                                ),
                              ),
                              const Text(
                                '11',
                                style: TextStyle(
                                  color: AppColors.deepBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Araboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.translate('soccerPractice'),
                                style: const TextStyle(
                                  color: AppColors.deepBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Araboto',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.translate('soccerPracticeTime'),
                                style: const TextStyle(
                                  color: AppColors.deepBlue,
                                  fontSize: 12,
                                  fontFamily: 'Araboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              FeatureCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEAF6FC), Color(0xFFFFE6D5)],
                ),
                onTap: () => onNavigate('photos'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.translate('memoryLane'),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Araboto',
                          ),
                        ),
                        Text(
                          t.translate('onThisDay'),
                          style: const TextStyle(
                            color: AppColors.deepBlue,
                            fontSize: 12,
                            fontFamily: 'Araboto',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [1, 2, 3].map((i) {
                        return Expanded(
                          child: Container(
                            margin: i < 3
                                ? const EdgeInsets.only(right: 8)
                                : EdgeInsets.zero,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryBlue.withValues(alpha:0.2),
                                  AppColors.accentOrange.withValues(alpha:0.2),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.translate('memoriesLastYear'),
                      style: TextStyle(
                        color: AppColors.deepBlue.withValues(alpha:0.7),
                        fontSize: 12,
                        fontFamily: 'Araboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              FeatureCard(
                color: Colors.white,
                onTap: () => onNavigate('settings'),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.softBlueBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.translate('settings'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Araboto',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.translate('settingsSubtitle'),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Araboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}