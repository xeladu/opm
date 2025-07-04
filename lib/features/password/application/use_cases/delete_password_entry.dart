import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';

class DeletePasswordEntry {
  final PasswordRepository repository;

  DeletePasswordEntry(this.repository);

  Future<void> call(String id) async {
    await repository.deletePasswordEntry(id);
  }
}
