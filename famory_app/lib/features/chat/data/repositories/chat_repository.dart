import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  ChatRepository({ChatService? service}) : _service = service ?? ChatService();

  final ChatService _service;

  Future<List<MessageModel>> getFamilyHistory(String familyId) {
    return _service.getFamilyHistory(familyId);
  }

  Future<List<MessageModel>> getPrivateHistory(String otherUserId) {
    return _service.getPrivateHistory(otherUserId);
  }

  Future<MessageModel> sendFamilyMessage({
    required String familyId,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) {
    return _service.sendFamilyMessage(
      familyId: familyId,
      message: message,
      metadata: metadata,
    );
  }

  Future<MessageModel> sendPrivateMessage({
    required String recipientId,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) {
    return _service.sendPrivateMessage(
      recipientId: recipientId,
      message: message,
      metadata: metadata,
    );
  }
}
