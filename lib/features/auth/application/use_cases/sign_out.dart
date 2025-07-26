import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}
