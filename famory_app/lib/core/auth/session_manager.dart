import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum SessionStatus {
  unauthenticated,
  authenticated,
  expired,
}

class SessionManager {
  const SessionManager._();

  static Future<SessionStatus> status() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final token = prefs.getString('auth_token')?.trim();

    if (!isLoggedIn || token == null || token.isEmpty) {
      return SessionStatus.unauthenticated;
    }

    if (isTokenExpired(token)) {
      await clearSession();
      return SessionStatus.expired;
    }

    return SessionStatus.authenticated;
  }

  static bool isTokenExpired(String token) {
    final expiry = tokenExpiry(token);
    if (expiry == null) {
      return false;
    }

    return !DateTime.now().toUtc().isBefore(expiry);
  }

  static DateTime? tokenExpiry(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final exp = decoded['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }

      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_logged_in');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_data');
    await prefs.remove('profile_image_path');
  }
}
