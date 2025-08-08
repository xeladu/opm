import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

abstract class ImportRepository {
  void validateOpmFile(String csvContent);
  Future<List<VaultEntry>> importFromOpm(String csvContent);
  void validateBitwardenFile(String csvContent);
  Future<List<VaultEntry>> importFromBitwarden(String csvContent);
  void validate1PasswordFile(String csvContent);
  Future<List<VaultEntry>> importFrom1Password(String csvContent);
  void validateLastPassFile(String csvContent);
  Future<List<VaultEntry>> importFromLastPass(String csvContent);
  void validateKeeperFile(String csvContent);
  Future<List<VaultEntry>> importFromKeeper(String csvContent);
  void validateKeepassFile(String csvContent);
  Future<List<VaultEntry>> importFromKeepass(String csvContent);
}
