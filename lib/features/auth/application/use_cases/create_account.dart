import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';

class CreateAccount {
  final AuthRepository repository;

  CreateAccount(this.repository);

  Future<void> call({required String email, required String password}) async {
    await repository.createAccount(email: email, password: password);
  }
}
