abstract class BiometricAuthRepository {
  Future<bool> isSupported();
  Future<bool> authenticate();
}
