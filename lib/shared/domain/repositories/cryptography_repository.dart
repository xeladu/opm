abstract class CryptographyRepository {
  Future<void> init(String password, {String? sharedSalt});
  void dispose();
  Future<String> encrypt(String plainText);
  Future<String> decrypt(String encrypted);
  String? getCurrentSalt();
}
