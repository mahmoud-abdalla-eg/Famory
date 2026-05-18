import 'package:flutter/services.dart';

class EnvConfig {
  static const String _envAssetPath = '.env';
  static const String _defaultBaseUrl = 'http://localhost:5000';

  static final Map<String, String> _values = {};

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString(_envAssetPath);
      _values
        ..clear()
        ..addAll(_parse(raw));
    } catch (_) {
      _values.clear();
    }
  }

  static String get apiBaseUrl {
    return _read('API_BASE_URL', fallback: _defaultBaseUrl);
  }

  static String? get frontendAuthToken {
    final value = _read('FRONTEND_AUTH_TOKEN');
    return value.isEmpty ? null : value;
  }

  static String? get openAiApiKey {
    final value = _read('OPENAI_API_KEY');
    return value.isEmpty ? null : value;
  }

  static String? get deepSeekApiKey {
    final value = _read('DEEPSEEK_API_KEY', fallback: openAiApiKey ?? '');
    return value.isEmpty ? null : value;
  }

  static String get deepSeekBaseUrl {
    return _read('DEEPSEEK_BASE_URL', fallback: 'https://api.deepseek.com');
  }

  static String get deepSeekModel {
    return _read('DEEPSEEK_MODEL', fallback: 'deepseek-v4-flash');
  }

  static String? authTokenFallback(String? savedToken) {
    final token = savedToken?.trim();
    if (token != null && token.isNotEmpty) {
      return token;
    }

    final fallbackToken = frontendAuthToken?.trim();
    if (fallbackToken == null || fallbackToken.isEmpty || !_looksLikeJwt(fallbackToken)) {
      return null;
    }

    return fallbackToken;
  }

  static String _read(String key, {String fallback = ''}) {
    const envValues = {
      'API_BASE_URL': String.fromEnvironment('API_BASE_URL'),
      'FRONTEND_AUTH_TOKEN': String.fromEnvironment('FRONTEND_AUTH_TOKEN'),
      'DEEPSEEK_BASE_URL': String.fromEnvironment('DEEPSEEK_BASE_URL'),
      'DEEPSEEK_API_KEY': String.fromEnvironment('DEEPSEEK_API_KEY'),
      'DEEPSEEK_MODEL': String.fromEnvironment('DEEPSEEK_MODEL'),
      'OPENAI_API_KEY': String.fromEnvironment('OPENAI_API_KEY'),
    };

    final dartDefineValue = envValues[key]?.trim();
    if (dartDefineValue != null && dartDefineValue.isNotEmpty) {
      return dartDefineValue;
    }

    final fileValue = _values[key]?.trim();
    if (fileValue != null && fileValue.isNotEmpty) {
      return fileValue;
    }

    return fallback;
  }

  static Map<String, String> _parse(String raw) {
    final values = <String, String>{};
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();
      final value = trimmed.substring(separatorIndex + 1).trim();
      values[key] = _stripQuotes(value);
    }

    return values;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) {
      return value;
    }

    final startsWithSingle = value.startsWith("'");
    final endsWithSingle = value.endsWith("'");
    final startsWithDouble = value.startsWith('"');
    final endsWithDouble = value.endsWith('"');
    if ((startsWithSingle && endsWithSingle) ||
        (startsWithDouble && endsWithDouble)) {
      return value.substring(1, value.length - 1);
    }

    return value;
  }

  static bool _looksLikeJwt(String value) {
    return value.split('.').length == 3;
  }
}
