abstract class CryptographyRepository {
  Future<void> init(String password);
  void dispose();
  Future<String> encrypt(String plainText);
  Future<String> decrypt(String encrypted);
}
