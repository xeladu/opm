abstract class SaltRepository {
  Future<String?> getUserSalt(String userId);
  Future<void> saveUserSalt(String userId, String salt);
}
