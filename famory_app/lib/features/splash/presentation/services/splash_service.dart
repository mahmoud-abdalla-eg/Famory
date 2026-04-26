import 'package:flutter/foundation.dart'; // Add this for debugPrint
import 'package:shared_preferences/shared_preferences.dart';

class SplashService {
  SplashService();

  /// Check if user is authenticated
  Future<bool> checkAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking authentication: $e'); // Now this will work
      return false;
    }
  }

  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      debugPrint('Error checking onboarding state: $e');
      return false;
    }
  }

  /// Initialize app services
  Future<void> initializeServices() async {
    try {
      await _initializePreferences();
      await _initializeDatabase();
      await _syncData();
    } catch (e) {
      debugPrint('Error initializing services: $e'); // Now this will work
    }
  }

  Future<void> _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('onboarding_completed')) {
      await prefs.setBool('onboarding_completed', false);
    }
  }

  Future<void> _initializeDatabase() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _syncData() async {
    final isLoggedIn = await checkAuthentication();
    if (isLoggedIn) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
