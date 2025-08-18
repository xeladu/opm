import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

abstract class VaultRepository {
  Future<void> addEntry(VaultEntry entry);
  Future<void> editEntry(VaultEntry entry);
  Future<void> deleteEntry(String id);
  Future<List<VaultEntry>> getAllEntries({Function(String info)? onUpdate});
}
