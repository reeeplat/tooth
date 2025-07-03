abstract class AuthStrategy {
  Future<bool> login(String userId, String password);
  Future<bool> register(String userId, String password, String name);
  Future<void> logout();
}