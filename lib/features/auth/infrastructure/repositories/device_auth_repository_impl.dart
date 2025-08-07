import 'package:local_auth/local_auth.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/entities/credentials.dart';
import 'package:open_password_manager/features/auth/domain/repositories/device_auth_repository.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

class DeviceAuthRepositoryImpl implements DeviceAuthRepository {
  final StorageService _storageService;
  final LocalAuthentication auth = LocalAuthentication();

  DeviceAuthRepositoryImpl(this._storageService);

  @override
  Future<Credentials> authenticate() async {
    try {
      final result = await auth.authenticate(
        localizedReason: "Authenticate to unlock",
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(signInTitle: "Unlock OPM"),
          IOSAuthMessages(localizedFallbackTitle: "Unlock OPM"),
          WindowsAuthMessages(),
        ],
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (!result) return Credentials.empty();

      final credentials = await _storageService.loadAuthCredentials();
      return credentials;
    } catch (ex) {
      return Credentials.empty();
    }
  }

  @override
  Future<bool> isSupported() async {
    try {
      final deviceSupport = await auth.isDeviceSupported();
      final allBiometrics = await auth.getAvailableBiometrics();
      final hasAnyBiometrics =
          allBiometrics.contains(BiometricType.face) ||
          allBiometrics.contains(BiometricType.iris) ||
          allBiometrics.contains(BiometricType.fingerprint) ||
          allBiometrics.contains(BiometricType.strong);

      return deviceSupport && hasAnyBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasStoredCredentials() async {
    try {
      final credentials = await _storageService.loadAuthCredentials();

      return credentials != Credentials.empty();
    } catch (_) {
      return false;
    }
  }
}
