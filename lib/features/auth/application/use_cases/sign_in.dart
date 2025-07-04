import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<void> call({required String email, required String password}) async {
    await repository.signIn(email: email, password: password);
  }
}
