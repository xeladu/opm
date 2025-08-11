import 'package:local_auth/local_auth.dart';
import 'package:open_password_manager/features/auth/domain/exceptions/biometric_exception.dart';
import 'package:open_password_manager/features/auth/domain/repositories/biometric_auth_repository.dart';

class BiometricAuthRepositoryImpl implements BiometricAuthRepository {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> isSupported() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Unlock to open vault',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      return didAuthenticate;
    } catch (ex) {
      throw BiometricAuthException(ex.toString());
    }
  }
}
