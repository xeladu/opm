import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

abstract class ImportRepository {
  Future<List<VaultEntry>> importFromBitwarden(String csvContent);
  Future<List<VaultEntry>> importFrom1Password(String csvContent);
  Future<List<VaultEntry>> importFromLastPass(String csvContent);
  Future<List<VaultEntry>> importFromKeeper(String csvContent);
  Future<List<VaultEntry>> importFromKeepass(String csvContent);
}
