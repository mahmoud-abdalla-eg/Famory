import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/album_model.dart';
import '../models/memory_model.dart';

class MemoryLibrary {
  final List<AlbumModel> albums;
  final List<MemoryPhotoModel> photos;

  const MemoryLibrary({
    required this.albums,
    required this.photos,
  });
}

class MemoryService {
  static const String _storageKey = 'encrypted_memory_library_v1';
  static const String _envelopeKey = 'famoryPhotoE2EE';
  static const String _appPepper =
      'famory-memory-photo-e2ee-v1-client-message-pepper';

  final Random _random = Random.secure();

  Future<MemoryLibrary> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const MemoryLibrary(albums: [], photos: []);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const MemoryLibrary(albums: [], photos: []);
      }

      final albums = decoded['albums'] is List
          ? (decoded['albums'] as List)
              .whereType<Map>()
              .map((album) => AlbumModel.fromJson(Map<String, dynamic>.from(album)))
              .toList()
          : <AlbumModel>[];
      final photos = decoded['photos'] is List
          ? (decoded['photos'] as List)
              .whereType<Map>()
              .map((photo) => MemoryPhotoModel.fromJson(Map<String, dynamic>.from(photo)))
              .toList()
          : <MemoryPhotoModel>[];

      return MemoryLibrary(albums: albums, photos: photos);
    } catch (_) {
      return const MemoryLibrary(albums: [], photos: []);
    }
  }

  Future<List<MemoryPhotoModel>> addEncryptedPhotos(List<File> files) async {
    final library = await loadLibrary();
    final createdPhotos = <MemoryPhotoModel>[];
    final photoDir = await _photoDirectory();

    for (final file in files) {
      final bytes = await file.readAsBytes();
      final id = DateTime.now().microsecondsSinceEpoch.toString() +
          _random.nextInt(999999).toString().padLeft(6, '0');
      final encryptedPath = '${photoDir.path}${Platform.pathSeparator}$id.famory';
      final encryptedBytes = _encryptBytes(bytes, id);
      await File(encryptedPath).writeAsBytes(encryptedBytes, flush: true);
      createdPhotos.add(
        MemoryPhotoModel(
          id: id,
          encryptedPath: encryptedPath,
          originalName: file.uri.pathSegments.isEmpty
              ? 'Photo'
              : file.uri.pathSegments.last,
          createdAt: DateTime.now(),
        ),
      );
    }

    await _saveLibrary(
      albums: library.albums,
      photos: [...library.photos, ...createdPhotos],
    );

    return createdPhotos;
  }

  Future<AlbumModel> createAlbum({
    required String title,
    required List<String> photoIds,
  }) async {
    final library = await loadLibrary();
    final album = AlbumModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'New Album' : title.trim(),
      createdAt: DateTime.now(),
      photoIds: photoIds,
    );
    final updatedPhotos = library.photos
        .map((photo) =>
            photoIds.contains(photo.id) ? photo.copyWith(albumId: album.id) : photo)
        .toList();

    await _saveLibrary(
      albums: [...library.albums, album],
      photos: updatedPhotos,
    );

    return album;
  }

  Future<Uint8List?> decryptPhoto(MemoryPhotoModel photo) async {
    try {
      final bytes = await File(photo.encryptedPath).readAsBytes();
      return Uint8List.fromList(_decryptBytes(bytes, photo.id));
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLibrary({
    required List<AlbumModel> albums,
    required List<MemoryPhotoModel> photos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'albums': albums.map((album) => album.toJson()).toList(),
        'photos': photos.map((photo) => photo.toJson()).toList(),
      }),
    );
  }

  Future<Directory> _photoDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}${Platform.pathSeparator}famory_encrypted_photos');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  List<int> _encryptBytes(List<int> plainBytes, String photoId) {
    final nonce = _randomBytes(24);
    final rootKey = _rootKey(photoId);
    final cipherBytes = _xorWithKeyStream(
      input: plainBytes,
      key: _deriveKey(rootKey, 'enc:$photoId'),
      nonce: nonce,
    );
    final macBytes = _mac(
      key: _deriveKey(rootKey, 'mac:$photoId'),
      parts: [nonce, cipherBytes],
    );

    return utf8.encode(
      jsonEncode({
        _envelopeKey: {
          'v': 1,
          'alg': 'hmac-sha256-stream',
          'nonce': base64Encode(nonce),
          'ciphertext': base64Encode(cipherBytes),
          'mac': base64Encode(macBytes),
        },
      }),
    );
  }

  List<int> _decryptBytes(List<int> encryptedBytes, String photoId) {
    final decoded = jsonDecode(utf8.decode(encryptedBytes));
    final envelope = decoded is Map<String, dynamic> ? decoded[_envelopeKey] : null;
    if (envelope is! Map) {
      throw const FormatException('Invalid encrypted photo.');
    }

    final nonce = base64Decode(envelope['nonce']?.toString() ?? '');
    final cipherBytes = base64Decode(envelope['ciphertext']?.toString() ?? '');
    final expectedMac = base64Decode(envelope['mac']?.toString() ?? '');
    final rootKey = _rootKey(photoId);
    final actualMac = _mac(
      key: _deriveKey(rootKey, 'mac:$photoId'),
      parts: [nonce, cipherBytes],
    );

    if (!_constantTimeEquals(expectedMac, actualMac)) {
      throw const FormatException('Encrypted photo failed integrity check.');
    }

    return _xorWithKeyStream(
      input: cipherBytes,
      key: _deriveKey(rootKey, 'enc:$photoId'),
      nonce: nonce,
    );
  }

  List<int> _rootKey(String photoId) {
    return Hmac(sha256, utf8.encode(_appPepper)).convert(utf8.encode(photoId)).bytes;
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
}
