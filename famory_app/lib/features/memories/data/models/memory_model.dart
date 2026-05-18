class MemoryPhotoModel {
  final String id;
  final String encryptedPath;
  final String originalName;
  final DateTime createdAt;
  final String? albumId;

  const MemoryPhotoModel({
    required this.id,
    required this.encryptedPath,
    required this.originalName,
    required this.createdAt,
    this.albumId,
  });

  factory MemoryPhotoModel.fromJson(Map<String, dynamic> json) {
    return MemoryPhotoModel(
      id: json['id']?.toString() ?? '',
      encryptedPath: json['encryptedPath']?.toString() ?? '',
      originalName: json['originalName']?.toString() ?? 'Photo',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      albumId: json['albumId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encryptedPath': encryptedPath,
      'originalName': originalName,
      'createdAt': createdAt.toIso8601String(),
      'albumId': albumId,
    };
  }

  MemoryPhotoModel copyWith({
    String? id,
    String? encryptedPath,
    String? originalName,
    DateTime? createdAt,
    String? albumId,
  }) {
    return MemoryPhotoModel(
      id: id ?? this.id,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      originalName: originalName ?? this.originalName,
      createdAt: createdAt ?? this.createdAt,
      albumId: albumId ?? this.albumId,
    );
  }
}
