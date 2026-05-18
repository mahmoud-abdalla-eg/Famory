import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
// import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart'; // Using the existing one
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/session_expired_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/app_container.dart';
import '../../features/family/presentation/screens/create_family_basic_screen.dart';
import '../../features/family/presentation/screens/create_family_invite_screen.dart';
import '../../features/family/presentation/screens/create_family_role_screen.dart';
import '../../features/family/presentation/screens/join_family_options_screen.dart';
import '../../features/family/presentation/screens/join_family_preview_screen.dart';
import '../../features/family/presentation/screens/join_family_setup_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String sessionExpired = '/session-expired';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String familyJoin = '/family-join';
  static const String familyJoinPreview = '/family-join-preview';
  static const String familyJoinSetup = '/family-join-setup';
  static const String familyCreate = '/family-create';
  static const String familyCreateRole = '/family-create-role';
  static const String familyInvite = '/family-invite';

  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    // Using the existing onboarding_screen as the initial welcome screen for now
    GetPage(
      name: onboarding,
      page: () => OnboardingScreen(
        onComplete: () {
          _markOnboardingComplete();
          Get.offAllNamed(login);
        },
      ),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: sessionExpired,
      page: () => const SessionExpiredScreen(),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: home,
      page: () => AppContainer(
        onChangeLanguage: (code) => Get.updateLocale(Locale(code)),
        currentLocale: Get.locale ?? const Locale('en'),
      ), // Using existing AppContainer as base
    ),
    GetPage(
      name: familyJoin,
      page: () => const JoinFamilyOptionsScreen(),
    ),
    GetPage(
      name: familyJoinPreview,
      page: () => const JoinFamilyPreviewScreen(),
    ),
    GetPage(
      name: familyJoinSetup,
      page: () => const JoinFamilySetupScreen(),
    ),
    GetPage(
      name: familyCreate,
      page: () => const CreateFamilyBasicScreen(),
    ),
    GetPage(
      name: familyCreateRole,
      page: () => const CreateFamilyRoleScreen(),
    ),
    GetPage(
      name: familyInvite,
      page: () => const CreateFamilyInviteScreen(),
    ),
  ];

  static Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}
