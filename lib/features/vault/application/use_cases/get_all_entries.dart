import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

class GetAllEntries {
  final EntryRepository repository;

  GetAllEntries(this.repository);

  Future<List<VaultEntry>> call() async {
    return await repository.getAllEntries();
  }
}
