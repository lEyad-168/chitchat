abstract interface class AuthRepositoryInterface {
  Future<String?> loginWithEmailAndPassword(String email, String password);
  Future<String?> registerWithEmailAndPassword(
      String name, String email, String password);
  Future<void> logout();
}
