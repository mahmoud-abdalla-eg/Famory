import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../services/splash_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashService _splashService = SplashService();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    final isLoggedIn = await _splashService.checkAuthentication();
    final onboardingCompleted = await _splashService.isOnboardingCompleted();

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      final authProvider = Get.isRegistered<AuthProvider>()
          ? Get.find<AuthProvider>()
          : Get.put(AuthProvider(), permanent: true);
      await authProvider.restoreSession();

      if (!mounted) {
        return;
      }

      Get.offAllNamed(AppRoutes.home);
    } else if (onboardingCompleted) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Icon(Icons.home_rounded, color: Colors.white, size: 46),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'One Famory',
                style: AppTextStyles.displayLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                'One Place for Family Life',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.g400, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 22),
              const ThreeDotsLoader(),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreeDotsLoader extends StatefulWidget {
  const ThreeDotsLoader({super.key});

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double value = _controller.value;
            // Calculate delay for each dot (0.0, 0.25, 0.5)
            double delay = index * 0.25;
            double adjustedValue = (value - delay) % 1.0;
            if (adjustedValue < 0) adjustedValue += 1.0;
            
            // Opacity pulses from 0.2 to 1.0 to 0.2
            double opacity = 0.2;
            if (adjustedValue < 0.5) {
              opacity = 0.2 + (0.8 * (adjustedValue / 0.5));
            } else {
              opacity = 1.0 - (0.8 * ((adjustedValue - 0.5) / 0.5));
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
