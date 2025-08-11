abstract class CryptographyRepository {
  Future<String> encrypt(String plainText);
  Future<String> decrypt(String plainText);
}
