class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? role;
  final String? token;
  final String? profilePhoto;
  final Map<String, dynamic> raw;

  const UserModel({
    required this.name,
    required this.email,
    this.id,
    this.role,
    this.token,
    this.profilePhoto,
    this.raw = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = _extractUserData(json);
    return UserModel(
      id: _readString(userData, ['id', '_id', 'userId']),
      name: _readFullName(userData) ??
          'User',
      email: _readString(userData, ['email']) ?? '',
      role: _readString(userData, ['role', 'type']),
      token: _extractToken(json),
      profilePhoto: _readString(userData, ['profilePhoto', 'avatarUrl', 'profileImage', 'photoUrl', 'image']),
      raw: userData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...raw,
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'profilePhoto': profilePhoto,
    };
  }

  static Map<String, dynamic> _extractUserData(Map<String, dynamic> json) {
    final nested = json['user'] ?? json['data'] ?? json['result'];
    if (nested is Map<String, dynamic>) {
      return Map<String, dynamic>.from(nested);
    }

    return Map<String, dynamic>.from(json);
  }

  static String? _extractToken(Map<String, dynamic> json) {
    const tokenKeys = ['token', 'accessToken', 'jwt', 'authToken'];
    for (final key in tokenKeys) {
      final directValue = json[key];
      if (directValue is String && directValue.isNotEmpty) {
        return directValue;
      }
    }

    final nested = json['data'] ?? json['user'];
    if (nested is Map<String, dynamic>) {
      for (final key in tokenKeys) {
        final nestedValue = nested[key];
        if (nestedValue is String && nestedValue.isNotEmpty) {
          return nestedValue;
        }
      }
    }

    return null;
  }

  static String? _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String? fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final stringValue = value.toString();
        if (stringValue.isNotEmpty) {
          return stringValue;
        }
      }
    }

    return fallback;
  }

  static String? _readFullName(Map<String, dynamic> json) {
    final directName = _readString(
      json,
      ['fullname', 'name', 'fullName', 'username'],
    );
    if (directName != null) {
      return directName;
    }

    final firstName = _readString(json, ['firstname', 'firstName']);
    final lastName = _readString(json, ['lastname', 'lastName']);
    final fullName = [firstName, lastName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    return fullName.isEmpty ? null : fullName;
  }
}
