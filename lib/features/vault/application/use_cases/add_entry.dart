import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

class AddEntry {
  final EntryRepository repository;

  AddEntry(this.repository);

  Future<void> call(VaultEntry entry) async {
    await repository.addEntry(entry);
  }
}
