import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chitchat/features/auth/data/repositories/auth_repository.dart';
import 'package:chitchat/features/auth/domain/repositories/auth_repository_interface.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

class AuthController {
  final AuthRepositoryInterface _authRepository;

  AuthController(this._authRepository);

  Future<String?> loginWithEmailAndPassword(
      String email, String password) async {
    return await _authRepository.loginWithEmailAndPassword(email, password);
  }

  Future<String?> registerWithEmailAndPassword(
      String name, String email, String password) async {
    return await _authRepository.registerWithEmailAndPassword(
        name, email, password);
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
