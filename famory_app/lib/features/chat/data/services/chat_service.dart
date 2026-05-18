import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/env_config.dart';
import '../models/message_model.dart';
import 'chat_crypto_service.dart';

class ChatService {
  ChatService({ChatCryptoService? cryptoService})
      : _cryptoService = cryptoService ?? ChatCryptoService();

  final ChatCryptoService _cryptoService;

  Future<List<MessageModel>> getFamilyHistory(String familyId) async {
    final response = await _requestJson(
      method: 'GET',
      path: '/api/chats/history/family/$familyId',
    );

    return _decryptMessages(
      conversationId: _familyConversationId(familyId),
      messages: _extractMessages(response),
    );
  }

  Future<List<MessageModel>> getPrivateHistory(String otherUserId) async {
    final currentUserId = await _currentUserId();
    final response = await _requestJson(
      method: 'GET',
      path: '/api/chats/history/private/$otherUserId',
    );

    return _decryptMessages(
      conversationId: _privateConversationId(currentUserId, otherUserId),
      messages: _extractMessages(response),
    );
  }

  Future<MessageModel> sendFamilyMessage({
    required String familyId,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) async {
    final encryptedMessage = await _cryptoService.encrypt(
      conversationId: _familyConversationId(familyId),
      plainText: message,
    );
    final response = await _requestJson(
      method: 'POST',
      path: '/api/chats/family',
      body: {
        'familyId': familyId,
        'message': encryptedMessage,
        'metadata': _encryptedMetadata(metadata),
      },
    );

    return _decryptMessage(
      conversationId: _familyConversationId(familyId),
      message: _extractMessage(response),
    );
  }

  Future<MessageModel> sendPrivateMessage({
    required String recipientId,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) async {
    final currentUserId = await _currentUserId();
    final conversationId = _privateConversationId(currentUserId, recipientId);
    final encryptedMessage = await _cryptoService.encrypt(
      conversationId: conversationId,
      plainText: message,
    );
    final response = await _requestJson(
      method: 'POST',
      path: '/api/chats/private',
      body: {
        'recipientId': recipientId,
        'message': encryptedMessage,
        'metadata': _encryptedMetadata(metadata),
      },
    );

    return _decryptMessage(
      conversationId: conversationId,
      message: _extractMessage(response),
    );
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.trim();
    if (token == null || token.isEmpty) {
      throw const ChatException('Please log in before using chat.');
    }

    if (_isExpiredJwt(token)) {
      await prefs.remove('auth_token');
      await prefs.setBool('is_logged_in', false);
      throw const ChatAuthException('Your session expired. Please log in again.');
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
        if (response.statusCode == 401) {
          await prefs.remove('auth_token');
          await prefs.setBool('is_logged_in', false);
          throw ChatAuthException(_messageFromResponse(responseData, response.statusCode));
        }

        throw ChatException(_messageFromResponse(responseData, response.statusCode));
      }

      return responseData;
    } on SocketException {
      throw ChatException('Unable to reach the chat server at ${EnvConfig.apiBaseUrl}.');
    } on FormatException catch (error) {
      throw ChatException('Invalid chat response: ${error.message}');
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

  MessageModel _extractMessage(Map<String, dynamic> response) {
    final chat = response['chat'] ?? response['message'] ?? response['data'] ?? response;
    if (chat is Map<String, dynamic>) {
      return MessageModel.fromJson(chat);
    }

    if (chat is Map) {
      return MessageModel.fromJson(Map<String, dynamic>.from(chat));
    }

    throw const ChatException('Invalid chat message from server.');
  }

  List<MessageModel> _extractMessages(Map<String, dynamic> response) {
    final chats = response['chats'] ?? response['messages'] ?? response['data'];
    if (chats is! List) {
      return const [];
    }

    return chats
        .whereType<Map>()
        .map((chat) => MessageModel.fromJson(Map<String, dynamic>.from(chat)))
        .toList();
  }

  Future<MessageModel> _decryptMessage({
    required String conversationId,
    required MessageModel message,
  }) async {
    final decryptedText = await _cryptoService.decrypt(
      conversationId: conversationId,
      message: message.message,
    );

    return message.copyWith(message: decryptedText);
  }

  Future<List<MessageModel>> _decryptMessages({
    required String conversationId,
    required List<MessageModel> messages,
  }) async {
    final decryptedMessages = <MessageModel>[];
    for (final message in messages) {
      decryptedMessages.add(
        await _decryptMessage(
          conversationId: conversationId,
          message: message,
        ),
      );
    }

    return decryptedMessages;
  }

  Map<String, dynamic> _encryptedMetadata(Map<String, dynamic> metadata) {
    return {
      ...metadata,
      'e2ee': true,
      'e2eeVersion': 1,
      'messageEncoding': 'famory-e2ee-json',
    };
  }

  Future<String> _currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id')?.trim();
    if (userId == null || userId.isEmpty) {
      throw const ChatException('Please log in before using chat.');
    }

    return userId;
  }

  String _familyConversationId(String familyId) {
    return 'family:$familyId';
  }

  String _privateConversationId(String currentUserId, String otherUserId) {
    final ids = [currentUserId, otherUserId]..sort();
    return 'private:${ids.join(':')}';
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

    return 'Chat request failed with status $statusCode.';
  }

  bool _isExpiredJwt(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return true;
    }

    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return true;
      }

      final exp = decoded['exp'];
      final seconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
      if (seconds == null) {
        return false;
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));
    } catch (_) {
      return true;
    }
  }
}

class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => message;
}

class ChatAuthException extends ChatException {
  const ChatAuthException(super.message);
}
