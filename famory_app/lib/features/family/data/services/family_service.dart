import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/env_config.dart';
import '../models/family_member.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  String? familyName;
  String? familyId;
  String? familyCode;
  String? ownerName;
  String? ownerRole;
  bool invitedLater = false;
  String? _currentUserKey;

  final List<FamilyMember> _members = [];

  List<FamilyMember> get members => List.unmodifiable(_members);
  bool get hasFamily => familyName != null && familyName!.trim().isNotEmpty;

  Future<void> loadForUser(String userKey) async {
    _currentUserKey = _normalizeUserKey(userKey);
    final loadedFromBackend = await _loadBackendFamily();
    if (loadedFromBackend) {
      await _saveForCurrentUser();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final rawState = prefs.getString(_storageKey);

    if (rawState == null || rawState.isEmpty) {
      reset();
      _currentUserKey = _normalizeUserKey(userKey);
      return;
    }

    final decoded = _decodeState(rawState);
    if (decoded == null) {
      reset();
      _currentUserKey = _normalizeUserKey(userKey);
      return;
    }

    _applyLocalState(decoded);
  }

  Future<void> createFamily({
    required String name,
    required String owner,
    required String role,
  }) async {
    final response = await _requestJson(
      method: 'POST',
      path: '/api/family',
      body: {
        'familyName': name.trim().isEmpty ? 'The Famory Family' : name.trim(),
      },
    );
    final family = _extractFamily(response);
    _applyBackendFamily(family);
    await _refreshMemberNamesFromBackend();
    ownerName = _preferredDisplayName(owner, ownerName) ?? 'You';
    ownerRole = role;
    await _renameCurrentUserMember(ownerName!, ownerRole);
    invitedLater = false;
    await _saveForCurrentUser();
  }

  Future<void> joinFamily({
    required String inviteCode,
    required String memberName,
    required String role,
  }) async {
    final cleanInviteCode = inviteCode.trim().toUpperCase();
    final response = await _requestJson(
      method: 'POST',
      path: '/api/family/join',
      body: {
        'inviteCode': cleanInviteCode,
      },
    );
    final family = _extractFamily(response);
    _applyBackendFamily(family);
    await _refreshMemberNamesFromBackend();
    ownerName = _preferredDisplayName(memberName, ownerName) ?? 'You';
    ownerRole = role;
    await _renameCurrentUserMember(ownerName!, ownerRole);
    invitedLater = false;
    await _saveForCurrentUser();
  }

  Future<void> markInviteLater() async {
    invitedLater = true;
    await _saveForCurrentUser();
  }

  Future<void> updateCurrentUserFamilyProfile({
    required String memberName,
    required String role,
  }) async {
    ownerName = _preferredDisplayName(memberName, ownerName) ?? 'You';
    ownerRole = role.trim().isEmpty ? ownerRole ?? 'Member' : role.trim();
    await _renameCurrentUserMember(ownerName!, ownerRole);
    await _saveForCurrentUser();
  }

  Future<String> requireFamilyCode() async {
    final existingCode = familyCode?.trim();
    if (existingCode != null && existingCode.isNotEmpty) {
      return existingCode;
    }

    final id = familyId?.trim();
    if (id == null || id.isEmpty) {
      throw const FamilyException('Create or join a family before inviting members.');
    }

    final response = await _requestJson(
      method: 'GET',
      path: '/api/family/$id',
    );
    _applyBackendFamily(_extractFamily(response));
    await _saveForCurrentUser();

    final refreshedCode = familyCode?.trim();
    if (refreshedCode == null || refreshedCode.isEmpty) {
      throw const FamilyException('The backend did not return a family invite code.');
    }

    return refreshedCode;
  }

  void reset() {
    familyName = null;
    familyId = null;
    familyCode = null;
    ownerName = null;
    ownerRole = null;
    invitedLater = false;
    _currentUserKey = null;
    _members.clear();
  }

  String get _storageKey => 'family_state_${_currentUserKey ?? 'anonymous'}';

  String _normalizeUserKey(String userKey) {
    final trimmed = userKey.trim();
    return trimmed.isEmpty ? 'anonymous' : trimmed;
  }

  Future<void> _saveForCurrentUser() async {
    if (_currentUserKey == null || !hasFamily) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'familyName': familyName,
        'familyId': familyId,
        'familyCode': familyCode,
        'ownerName': ownerName,
        'ownerRole': ownerRole,
        'invitedLater': invitedLater,
        'members': _members.map((member) => member.toJson()).toList(),
      }),
    );
  }

  Future<bool> _loadBackendFamily() async {
    final activeUserKey = _currentUserKey;
    final prefs = await SharedPreferences.getInstance();
    final cachedState = _decodeState(prefs.getString(_storageKey));
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) {
      return false;
    }

    try {
      final userResponse = await _requestJson(
        method: 'GET',
        path: '/api/V1/user/$userId',
      );
      final user = _extractUser(userResponse);
      final backendFamilyId = user['familyId']?.toString();
      if (backendFamilyId == null || backendFamilyId.isEmpty) {
        reset();
        _currentUserKey = activeUserKey;
        await prefs.remove(_storageKey);
        return true;
      }

      final familyResponse = await _requestJson(
        method: 'GET',
        path: '/api/family/$backendFamilyId',
      );
      _applyBackendFamily(_extractFamily(familyResponse));
      await _refreshMemberNamesFromBackend();
      _renameMember(
        userId: userId,
        displayName: _preferredDisplayName(
          _cachedDisplayName(cachedState, userId),
          _displayNameFromUser(user),
        ),
        role: _cachedRole(cachedState, userId),
      );
      return hasFamily;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic>? _decodeState(String? rawState) {
    if (rawState == null || rawState.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawState);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  void _applyLocalState(Map<String, dynamic> decoded) {
    familyName = decoded['familyName']?.toString();
    familyId = decoded['familyId']?.toString();
    familyCode = decoded['familyCode']?.toString();
    ownerName = decoded['ownerName']?.toString();
    ownerRole = decoded['ownerRole']?.toString();
    invitedLater = decoded['invitedLater'] == true;

    final savedMembers = decoded['members'];
    _members
      ..clear()
      ..addAll(
        savedMembers is List
            ? savedMembers
                .whereType<Map>()
                .map((member) => FamilyMember.fromJson(Map<String, dynamic>.from(member)))
            : const <FamilyMember>[],
      );
  }

  Map<String, dynamic> _extractFamily(Map<String, dynamic> response) {
    final family = response['family'] ?? response['data'] ?? response;
    if (family is Map<String, dynamic>) {
      return family;
    }

    if (family is Map) {
      return Map<String, dynamic>.from(family);
    }

    throw const FamilyException('Invalid family response from server.');
  }

  Map<String, dynamic> _extractUser(Map<String, dynamic> response) {
    final user = response['user'] ?? response['data'] ?? response['result'] ?? response;
    if (user is Map<String, dynamic>) {
      return user;
    }

    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }

    return response;
  }

  void _applyBackendFamily(Map<String, dynamic> family) {
    familyName = family['familyName']?.toString();
    familyId = (family['_id'] ?? family['id'])?.toString();
    familyCode = (family['inviteCode'] ??
            family['familyCode'] ??
            family['invite_code'] ??
            family['code'])
        ?.toString();

    final backendMembers = family['members'];
    _members
      ..clear()
      ..addAll(
        backendMembers is List
            ? backendMembers
                .whereType<Map>()
                .map((member) => FamilyMember.fromJson(Map<String, dynamic>.from(member)))
            : const <FamilyMember>[],
      );

    final prefsOwnerName = _members.isNotEmpty ? _members.first.name : null;
    final prefsOwnerRole = _members.isNotEmpty ? _members.first.role : null;
    ownerName = prefsOwnerName;
    ownerRole = prefsOwnerRole;
  }

  Future<void> _refreshMemberNamesFromBackend() async {
    for (var index = 0; index < _members.length; index++) {
      final member = _members[index];
      if (member.id.isEmpty) {
        continue;
      }

      final user = await _fetchUser(member.id);
      final fullName = _displayNameFromUser(user);
      final cleanName = _safeDisplayName(fullName ?? member.name);
      if (cleanName == null) {
        continue;
      }

      _members[index] = FamilyMember(
        id: member.id,
        name: cleanName,
        avatarUrl: member.avatarUrl,
        role: member.role,
        tasksCompleted: member.tasksCompleted,
        tasksPending: member.tasksPending,
        isOnline: member.isOnline,
      );
    }

    if (_members.isNotEmpty) {
      ownerName = _members.first.name;
      ownerRole = _members.first.role;
    }
  }

  Future<Map<String, dynamic>> _fetchUser(String userId) async {
    try {
      final response = await _requestJson(
        method: 'GET',
        path: '/api/V1/user/$userId',
      );
      return _extractUser(response);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<void> _renameCurrentUserMember(String displayName, String? role) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) {
      return;
    }

    _renameMember(userId: userId, displayName: displayName, role: role);
  }

  void _renameMember({
    required String userId,
    required String? displayName,
    required String? role,
  }) {
    final cleanName = displayName?.trim();
    if (cleanName == null || cleanName.isEmpty) {
      return;
    }

    final memberIndex = _members.indexWhere((member) => member.id == userId);
    if (memberIndex == -1) {
      ownerName = cleanName;
      ownerRole = role ?? ownerRole;
      return;
    }

    final current = _members[memberIndex];
    _members[memberIndex] = FamilyMember(
      id: current.id,
      name: cleanName,
      avatarUrl: current.avatarUrl,
      role: role ?? current.role,
      tasksCompleted: current.tasksCompleted,
      tasksPending: current.tasksPending,
      isOnline: current.isOnline,
    );
    ownerName = cleanName;
    ownerRole = role ?? current.role;
  }

  String? _cachedDisplayName(Map<String, dynamic>? cachedState, String userId) {
    return _cachedMemberValue(cachedState, userId, 'name') ??
        cachedState?['ownerName']?.toString();
  }

  String? _cachedRole(Map<String, dynamic>? cachedState, String userId) {
    return _cachedMemberValue(cachedState, userId, 'role') ??
        cachedState?['ownerRole']?.toString();
  }

  String? _cachedMemberValue(
    Map<String, dynamic>? cachedState,
    String userId,
    String key,
  ) {
    final members = cachedState?['members'];
    if (members is! List) {
      return null;
    }

    for (final member in members.whereType<Map>()) {
      final id = (member['userId'] ?? member['id'] ?? member['_id'])?.toString();
      if (id == userId) {
        final value = member[key]?.toString().trim();
        return value == null || value.isEmpty ? null : value;
      }
    }

    return null;
  }

  String? _displayNameFromUser(Map<String, dynamic> user) {
    final name = user['fullname'] ?? user['name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    final firstName = (user['firstname'] ?? user['firstName'])?.toString();
    final lastName = (user['lastname'] ?? user['lastName'])?.toString();
    final fullName = [firstName, lastName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    return user['email']?.toString();
  }

  String? _safeDisplayName(String? name) {
    final value = name?.trim();
    if (value == null ||
        value.isEmpty ||
        value.contains('@') ||
        value.toLowerCase() == 'user') {
      return null;
    }

    return value;
  }

  String? _preferredDisplayName(String? preferred, String? fallback) {
    return _safeDisplayName(preferred) ?? _safeDisplayName(fallback);
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = EnvConfig.authTokenFallback(prefs.getString('auth_token'));
    if (token == null || token.isEmpty) {
      throw const FamilyException('Please log in before using family features.');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.openUrl(method, _buildUri(path));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      if (body != null) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final responseText = await utf8.decodeStream(response);
      final decoded = responseText.isEmpty ? <String, dynamic>{} : jsonDecode(responseText);
      final responseData = _normalizeResponse(decoded);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FamilyException(_messageFromResponse(responseData, response.statusCode));
      }

      return responseData;
    } on SocketException {
      throw FamilyException('Unable to reach the family server at ${EnvConfig.apiBaseUrl}.');
    } on FormatException catch (error) {
      throw FamilyException('Invalid family response: ${error.message}');
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

  Map<String, dynamic> _normalizeResponse(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{'data': decoded};
  }

  String _messageFromResponse(Map<String, dynamic> response, int statusCode) {
    final message = response['msg'] ?? response['message'] ?? response['error'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    return 'Family request failed with status $statusCode.';
  }
}

class FamilyException implements Exception {
  final String message;

  const FamilyException(this.message);

  @override
  String toString() => message;
}
