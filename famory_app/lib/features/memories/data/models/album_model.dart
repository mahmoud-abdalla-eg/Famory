class AlbumModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<String> photoIds;

  const AlbumModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.photoIds = const [],
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Album',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      photoIds: (json['photoIds'] is List)
          ? (json['photoIds'] as List)
              .map((id) => id?.toString())
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'photoIds': photoIds,
    };
  }

  AlbumModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<String>? photoIds,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      photoIds: photoIds ?? this.photoIds,
    );
  }
}
