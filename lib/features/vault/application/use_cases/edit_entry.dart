import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

class EditEntry {
  final VaultRepository repository;

  EditEntry(this.repository);

  Future<void> call(VaultEntry entry) async {
    await repository.editEntry(entry);
  }
}
