enum ChatMessageType { family, private }

class MessageModel {
  final String id;
  final ChatMessageType chatType;
  final String conversationKey;
  final String? familyId;
  final String senderId;
  final String? recipientId;
  final String message;
  final Map<String, dynamic> metadata;
  final List<String> readBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MessageModel({
    required this.id,
    required this.chatType,
    required this.conversationKey,
    required this.senderId,
    required this.message,
    this.familyId,
    this.recipientId,
    this.metadata = const {},
    this.readBy = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: _readString(json, ['_id', 'id']) ?? '',
      chatType: _readChatType(json['chatType']),
      conversationKey: _readString(json, ['conversationKey']) ?? '',
      familyId: _readString(json, ['familyId']),
      senderId: _readString(json, ['senderId']) ?? '',
      recipientId: _readString(json, ['recipientId']),
      message: _readString(json, ['message']) ?? '',
      metadata: _readMap(json['metadata']),
      readBy: _readList(json['readBy']),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatType': chatType.name,
      'conversationKey': conversationKey,
      'familyId': familyId,
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'metadata': metadata,
      'readBy': readBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    ChatMessageType? chatType,
    String? conversationKey,
    String? familyId,
    String? senderId,
    String? recipientId,
    String? message,
    Map<String, dynamic>? metadata,
    List<String>? readBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatType: chatType ?? this.chatType,
      conversationKey: conversationKey ?? this.conversationKey,
      familyId: familyId ?? this.familyId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      readBy: readBy ?? this.readBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ChatMessageType _readChatType(dynamic value) {
    return value?.toString() == 'private'
        ? ChatMessageType.private
        : ChatMessageType.family;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final stringValue = value.toString().trim();
      if (stringValue.isNotEmpty && stringValue != 'null') {
        return stringValue;
      }
    }

    return null;
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return const {};
  }

  static List<String> _readList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item?.toString())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime? _readDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }
}
