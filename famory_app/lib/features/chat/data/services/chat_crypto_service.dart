import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class ChatCryptoService {
  static const String _envelopeKey = 'famoryE2EE';
  static const int _version = 1;
  static const String _appPepper =
      'famory-chat-e2ee-v1-client-message-pepper';

  final Random _random = Random.secure();

  Future<String> encrypt({
    required String conversationId,
    required String plainText,
  }) async {
    final rootKey = await _secretKeyFor(conversationId);
    final nonce = _randomBytes(24);
    final cipherBytes = _xorWithKeyStream(
      input: utf8.encode(plainText),
      key: _deriveKey(rootKey, 'enc:$conversationId'),
      nonce: nonce,
    );
    final macBytes = _mac(
      key: _deriveKey(rootKey, 'mac:$conversationId'),
      parts: [nonce, cipherBytes],
    );

    return jsonEncode({
      _envelopeKey: {
        'v': _version,
        'alg': 'hmac-sha256-stream',
        'nonce': base64Encode(nonce),
        'ciphertext': base64Encode(cipherBytes),
        'mac': base64Encode(macBytes),
      },
    });
  }

  Future<String> decrypt({
    required String conversationId,
    required String message,
  }) async {
    final envelope = _readEnvelope(message);
    if (envelope == null) {
      return message;
    }

    try {
      final rootKey = await _secretKeyFor(conversationId);
      final nonce = base64Decode(envelope['nonce']?.toString() ?? '');
      final cipherBytes = base64Decode(envelope['ciphertext']?.toString() ?? '');
      final expectedMac = base64Decode(envelope['mac']?.toString() ?? '');
      final actualMac = _mac(
        key: _deriveKey(rootKey, 'mac:$conversationId'),
        parts: [nonce, cipherBytes],
      );

      if (!_constantTimeEquals(expectedMac, actualMac)) {
        return 'Encrypted message could not be verified.';
      }

      final clearBytes = _xorWithKeyStream(
        input: cipherBytes,
        key: _deriveKey(rootKey, 'enc:$conversationId'),
        nonce: nonce,
      );

      return utf8.decode(clearBytes);
    } catch (_) {
      return 'Encrypted message unavailable on this device.';
    }
  }

  bool isEncrypted(String message) {
    return _readEnvelope(message) != null;
  }

  Future<List<int>> _secretKeyFor(String conversationId) async {
    return Hmac(sha256, utf8.encode(_appPepper))
        .convert(utf8.encode(conversationId))
        .bytes;
  }

  List<int> _deriveKey(List<int> rootKey, String label) {
    return Hmac(sha256, rootKey).convert(utf8.encode(label)).bytes;
  }

  List<int> _xorWithKeyStream({
    required List<int> input,
    required List<int> key,
    required List<int> nonce,
  }) {
    final output = List<int>.filled(input.length, 0);
    var offset = 0;
    var counter = 0;

    while (offset < input.length) {
      final counterBytes = [
        (counter >> 24) & 0xff,
        (counter >> 16) & 0xff,
        (counter >> 8) & 0xff,
        counter & 0xff,
      ];
      final streamBlock = Hmac(sha256, key).convert([...nonce, ...counterBytes]).bytes;
      for (var index = 0; index < streamBlock.length && offset < input.length; index++) {
        output[offset] = input[offset] ^ streamBlock[index];
        offset++;
      }
      counter++;
    }

    return output;
  }

  List<int> _mac({
    required List<int> key,
    required List<List<int>> parts,
  }) {
    return Hmac(sha256, key).convert(parts.expand((part) => part).toList()).bytes;
  }

  List<int> _randomBytes(int length) {
    return List<int>.generate(length, (_) => _random.nextInt(256));
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    var diff = 0;
    for (var index = 0; index < left.length; index++) {
      diff |= left[index] ^ right[index];
    }

    return diff == 0;
  }

  Map<String, dynamic>? _readEnvelope(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final envelope = decoded[_envelopeKey];
      if (envelope is Map<String, dynamic>) {
        return envelope;
      }

      if (envelope is Map) {
        return Map<String, dynamic>.from(envelope);
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
