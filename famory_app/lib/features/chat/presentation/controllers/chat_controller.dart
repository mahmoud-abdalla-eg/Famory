import 'package:get/get.dart';

import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';

class ChatController extends GetxController {
  ChatController({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  final ChatRepository _repository;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxnString errorMessage = RxnString();

  Future<void> loadFamilyHistory(String familyId) async {
    await _load(() => _repository.getFamilyHistory(familyId));
  }

  Future<void> loadPrivateHistory(String otherUserId) async {
    await _load(() => _repository.getPrivateHistory(otherUserId));
  }

  Future<MessageModel> sendFamilyMessage({
    required String familyId,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) async {
    return _send(
      () => _repository.sendFamilyMessage(
        familyId: familyId,
        message: message,
        metadata: metadata,
      ),
    );
  }

  Future<MessageModel> sendPrivateMessage({
    required String recipientId,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) async {
    return _send(
      () => _repository.sendPrivateMessage(
        recipientId: recipientId,
        message: message,
        metadata: metadata,
      ),
    );
  }

  Future<void> _load(Future<List<MessageModel>> Function() action) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      messages.assignAll(await action());
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<MessageModel> _send(Future<MessageModel> Function() action) async {
    isSending.value = true;
    errorMessage.value = null;
    try {
      final message = await action();
      messages.add(message);
      return message;
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isSending.value = false;
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    return text;
  }
}
