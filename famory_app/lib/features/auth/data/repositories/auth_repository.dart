import 'dart:io';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  Future<UserModel> login({
    required String email,
    required String password,
  }) {
    return _service.loginUser(
      email: email,
      password: password,
    );
  }

  Future<UserModel> signup({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? familyId,
  }) {
    return _service.registerUser(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      phone: phone,
      dateOfBirth: dateOfBirth,
      familyId: familyId,
    );
  }

  Future<void> logout() => _service.signOut();

  Future<UserModel?> currentUser() => _service.getCachedUser();

  Future<UserModel> updateProfilePhoto({
    required UserModel user,
    required File imageFile,
  }) {
    return _service.updateProfilePhoto(user: user, imageFile: imageFile);
  }

  Future<UserModel> removeProfilePhoto(UserModel user) {
    return _service.removeProfilePhoto(user);
  }
}
