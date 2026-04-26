import 'dart:io';

import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../family/data/services/family_service.dart';

class AuthProvider extends GetxController {
  AuthProvider({AuthRepository? repository}) : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return _runAction(() => _repository.login(email: email, password: password));
  }

  Future<UserModel> signup({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? familyId,
  }) async {
    return _runAction(
      () => _repository.signup(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: dateOfBirth,
        familyId: familyId,
      ),
    );
  }

  Future<void> logout() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repository.logout();
      currentUser.value = null;
      FamilyService().reset();
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel> updateProfilePhoto(File imageFile) async {
    final user = currentUser.value;
    if (user == null) {
      throw Exception('Please log in before updating your profile photo.');
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final updatedUser = await _repository.updateProfilePhoto(
        user: user,
        imageFile: imageFile,
      );
      currentUser.value = updatedUser;
      return updatedUser;
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel> removeProfilePhoto() async {
    final user = currentUser.value;
    if (user == null) {
      throw Exception('Please log in before removing your profile photo.');
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final updatedUser = await _repository.removeProfilePhoto(user);
      currentUser.value = updatedUser;
      return updatedUser;
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel?> restoreSession() async {
    final user = await _repository.currentUser();
    currentUser.value = user;
    if (user != null) {
      await FamilyService().loadForUser(_familyUserKey(user));
    }
    return user;
  }

  Future<UserModel> _runAction(Future<UserModel> Function() action) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = await action();
      currentUser.value = user;
      await FamilyService().loadForUser(_familyUserKey(user));
      return user;
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return text;
  }

  String _familyUserKey(UserModel user) {
    final id = user.id?.trim();
    if (id != null && id.isNotEmpty) {
      return id;
    }

    final email = user.email.trim();
    return email.isEmpty ? user.name : email;
  }
}
