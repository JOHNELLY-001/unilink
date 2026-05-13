/// Abstraction over the local session/token storage.
/// Real impl wraps secure storage (flutter_secure_storage).
abstract class AuthService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<bool> hasValidSession();
}