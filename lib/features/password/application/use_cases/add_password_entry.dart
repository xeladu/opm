import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';

class AddPasswordEntry {
  final PasswordRepository repository;

  AddPasswordEntry(this.repository);

  Future<void> call(PasswordEntry entry) async {
    await repository.addPasswordEntry(entry);
  }
}
