import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/domain/repositories/biometric_auth_repository.dart';

class BiometricSignIn {
  final AuthRepository authRepo;
  final BiometricAuthRepository biometricAuthRepo;

  BiometricSignIn(this.authRepo, this.biometricAuthRepo);

  Future<bool> call() async {
    final result = await biometricAuthRepo.authenticate();
    if (!result) return false;

    await authRepo.refreshSession();

    return true;
  }
}
