import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/env_config.dart';
import '../models/user_model.dart';

class AuthService {

  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _requestJson(
      method: 'POST',
      path: '/api/V1/user/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    final user = UserModel.fromJson(response);
    final token = user.token ?? _extractTokenFromResponse(response);

    if (token == null || token.isEmpty) {
      throw const AuthException('Login succeeded, but no session token was returned.');
    }

    final userId = user.id ?? _readTokenClaim(token, 'id');
    final tokenEmail = _readTokenClaim(token, 'email');
    final profile = await _fetchUserProfile(userId, token);
    final profileUser = profile == null ? null : UserModel.fromJson(profile);

      final authenticatedUser = UserModel(
        id: userId,
        name: _bestDisplayName([profileUser?.name, user.name, email]),
        email: _bestEmail([profileUser?.email, user.email, tokenEmail, email]),
        role: profileUser?.role ?? user.role,
        token: token,
        profilePhoto: _absoluteMediaUrl(profileUser?.profilePhoto ?? user.profilePhoto),
        raw: profileUser?.raw ?? user.raw,
      );

    await _saveSession(authenticatedUser);
    return authenticatedUser;
  }

  Future<UserModel> registerUser({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? familyId,
  }) async {
    final displayName = '${firstname.trim()} ${lastname.trim()}'.trim();
    final body = <String, dynamic>{
      'firstname': firstname.trim(),
      'lastname': lastname.trim(),
      'email': email.trim(),
      'password': password,
    };

    if (phone != null && phone.trim().isNotEmpty) {
      body['phone'] = phone.trim();
    }

    if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty) {
      body['dateOfBirth'] = dateOfBirth.trim();
    }

    if (familyId != null && familyId.trim().isNotEmpty) {
      body['familyId'] = familyId.trim();
    }

    final response = await _requestJson(
      method: 'POST',
      path: '/api/V1/user',
      body: body,
    );

    final user = UserModel.fromJson(response);
    final token = user.token ?? _extractTokenFromResponse(response);

    if (token != null && token.isNotEmpty) {
      final authenticatedUser = UserModel(
        id: user.id ?? _readTokenClaim(token, 'id'),
        name: _bestDisplayName([user.name, displayName, email]),
        email: user.email.isNotEmpty ? user.email : (_readTokenClaim(token, 'email') ?? email),
        role: user.role,
        token: token,
        profilePhoto: _absoluteMediaUrl(user.profilePhoto),
        raw: user.raw,
      );
      await _saveSession(authenticatedUser);
      return authenticatedUser;
    }

    // Some backends return the created user without a token.
    final loggedInUser = await loginUser(email: email, password: password);
    if (displayName.isEmpty) {
      return loggedInUser;
    }

    final namedUser = UserModel(
      id: loggedInUser.id,
      name: displayName,
      email: loggedInUser.email,
      role: loggedInUser.role,
      token: loggedInUser.token,
      profilePhoto: loggedInUser.profilePhoto,
      raw: loggedInUser.raw,
    );
    await _saveSession(namedUser);
    return namedUser;
  }

  Future<void> signOut() async {
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

  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData == null || userData.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(userData);
    if (decoded is Map<String, dynamic>) {
      return UserModel.fromJson(decoded);
    }

    return null;
  }

  Future<UserModel> updateProfilePhoto({
    required UserModel user,
    required File imageFile,
  }) async {
    final userId = user.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('No user id found for profile photo upload.');
    }

    final response = await _uploadProfilePhoto(
      userId: userId,
      ownerName: user.name,
      imageFile: imageFile,
      token: user.token,
    );
    final updatedUser = UserModel.fromJson(response);
    final profilePhoto = _absoluteMediaUrl(updatedUser.profilePhoto);
    final mergedUser = UserModel(
      id: updatedUser.id ?? user.id,
      name: _bestDisplayName([updatedUser.name, user.name]),
      email: _bestEmail([updatedUser.email, user.email]),
      role: updatedUser.role ?? user.role,
      token: user.token,
      profilePhoto: profilePhoto,
      raw: {
        ...user.raw,
        ...updatedUser.raw,
        if (profilePhoto != null) 'profilePhoto': profilePhoto,
        if (profilePhoto != null) 'avatarUrl': profilePhoto,
      },
    );

    await _saveSession(mergedUser);
    return mergedUser;
  }

  Future<UserModel> removeProfilePhoto(UserModel user) async {
    final userId = user.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('No user id found for profile photo removal.');
    }

    final response = await _requestJson(
      method: 'PUT',
      path: '/api/V1/user/$userId',
      token: user.token,
      body: {
        'profilePhoto': '',
        'avatarUrl': '',
      },
    );
    final updatedUser = UserModel.fromJson(response);
    final mergedUser = UserModel(
      id: updatedUser.id ?? user.id,
      name: _bestDisplayName([updatedUser.name, user.name]),
      email: _bestEmail([updatedUser.email, user.email]),
      role: updatedUser.role ?? user.role,
      token: user.token,
      raw: {
        ...user.raw,
        ...updatedUser.raw,
        'profilePhoto': '',
        'avatarUrl': '',
      },
    );

    await _saveSession(mergedUser);
    return mergedUser;
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.openUrl(method, _buildUri(path));
      request.headers.contentType = ContentType.json;

      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      if (body != null) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final responseText = await utf8.decodeStream(response);
      final decoded = responseText.isEmpty ? <String, dynamic>{} : jsonDecode(responseText);
      final responseData = _normalizeResponse(decoded);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(_messageFromResponse(responseData, response.statusCode));
      }

      return responseData;
    } on SocketException {
      throw AuthException('Unable to reach the auth server at ${EnvConfig.apiBaseUrl}.');
    } on FormatException catch (error) {
      throw AuthException('Invalid auth response: ${error.message}');
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _uploadProfilePhoto({
    required String userId,
    required String ownerName,
    required File imageFile,
    String? token,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);

    try {
      final request = await client.openUrl('PUT', _buildUri('/api/V1/user/$userId'));
      final boundary = 'famory-${DateTime.now().millisecondsSinceEpoch}';
      request.headers.contentType = ContentType('multipart', 'form-data', parameters: {'boundary': boundary});

      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      final fileName = imageFile.uri.pathSegments.isEmpty ? 'profile.jpg' : imageFile.uri.pathSegments.last;
      request.write('--$boundary\r\n');
      request.write('Content-Disposition: form-data; name="profileOwnerName"\r\n\r\n');
      request.write(ownerName);
      request.write('\r\n');
      request.write('--$boundary\r\n');
      request.write('Content-Disposition: form-data; name="profile"; filename="$fileName"\r\n');
      request.write('Content-Type: image/jpeg\r\n\r\n');
      await request.addStream(imageFile.openRead());
      request.write('\r\n--$boundary--\r\n');

      final response = await request.close();
      final responseText = await utf8.decodeStream(response);
      final decoded = responseText.isEmpty ? <String, dynamic>{} : jsonDecode(responseText);
      final responseData = _normalizeResponse(decoded);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(_messageFromResponse(responseData, response.statusCode));
      }

      return responseData;
    } on SocketException {
      throw AuthException('Unable to reach the auth server at ${EnvConfig.apiBaseUrl}.');
    } on FormatException catch (error) {
      throw AuthException('Invalid profile photo response: ${error.message}');
    } finally {
      client.close(force: true);
    }
  }

  Uri _buildUri(String path) {
    final uri = Uri.parse('${EnvConfig.apiBaseUrl}$path');
    if (Platform.isAndroid &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return uri.replace(host: '10.0.2.2');
    }

    return uri;
  }

  String? _absoluteMediaUrl(String? value) {
    final mediaPath = value?.trim();
    if (mediaPath == null || mediaPath.isEmpty) {
      return null;
    }

    if (mediaPath.startsWith('http://') || mediaPath.startsWith('https://')) {
      return mediaPath;
    }

    final base = Uri.parse(EnvConfig.apiBaseUrl);
    final host = Platform.isAndroid && (base.host == 'localhost' || base.host == '127.0.0.1')
        ? '10.0.2.2'
        : base.host;
    final normalizedPath = mediaPath.startsWith('/') ? mediaPath : '/$mediaPath';
    return base.replace(host: host, path: normalizedPath, query: '').toString();
  }

  Map<String, dynamic> _normalizeResponse(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }

    return <String, dynamic>{'data': decoded};
  }

  String _messageFromResponse(Map<String, dynamic> response, int statusCode) {
    final message = response['message'] ?? response['error'] ?? response['msg'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    return 'Request failed with status $statusCode.';
  }

  String? _extractTokenFromResponse(Map<String, dynamic> response) {
    const tokenKeys = ['token', 'accessToken', 'jwt', 'authToken'];

    for (final key in tokenKeys) {
      final value = response[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final nested = response['data'] ?? response['user'];
    if (nested is Map<String, dynamic>) {
      for (final key in tokenKeys) {
        final value = nested[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  String? _readTokenClaim(String token, String claim) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final value = decoded[claim];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String? userId, String token) async {
    if (userId == null || userId.isEmpty) {
      return null;
    }

    try {
      return await _requestJson(
        method: 'GET',
        path: '/api/V1/user/$userId',
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  String _bestDisplayName(List<String?> candidates) {
    for (final candidate in candidates) {
      final value = candidate?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }

      if (value.toLowerCase() == 'user' || value.contains('@')) {
        continue;
      }

      return value;
    }

    return candidates
            .map((candidate) => candidate?.trim())
            .whereType<String>()
            .firstWhere((value) => value.isNotEmpty, orElse: () => 'User');
  }

  String _bestEmail(List<String?> candidates) {
    for (final candidate in candidates) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  Future<void> _saveSession(UserModel user) async {
    if ((user.role ?? '').toLowerCase() == 'admin') {
      throw const AuthException('Admin accounts are not supported in this flow.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user.token ?? '');
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_id', user.id ?? '');
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role ?? 'user');
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
