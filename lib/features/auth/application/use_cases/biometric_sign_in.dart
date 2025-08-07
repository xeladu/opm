import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/domain/repositories/device_auth_repository.dart';

class BiometricSignIn {
  final AuthRepository authRepo;
  final DeviceAuthRepository deviceAuthRepo;

  BiometricSignIn(this.authRepo, this.deviceAuthRepo);

  Future<void> call() async {
    final creds = await deviceAuthRepo.authenticate();
    await authRepo.signIn(email: creds.email, password: creds.password);
  }
}
