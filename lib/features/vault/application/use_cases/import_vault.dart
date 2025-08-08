import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/repositories/import_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';

class ImportVault {
  final ImportRepository importRepo;
  final VaultRepository vaultRepo;

  ImportVault(this.vaultRepo, this.importRepo);

  Future<void> call(ImportProvider provider, String fileContent) async {
    List<VaultEntry> importedEntries = [];

    switch (provider) {
      case ImportProvider.onePassword:
        importRepo.validate1PasswordFile(fileContent);
        importedEntries = await importRepo.importFrom1Password(fileContent);
      case ImportProvider.bitwarden:
        importRepo.validateBitwardenFile(fileContent);
        importedEntries = await importRepo.importFromBitwarden(fileContent);
      case ImportProvider.keePass:
        importRepo.validateKeepassFile(fileContent);
        importedEntries = await importRepo.importFromKeepass(fileContent);
      case ImportProvider.keeper:
        importRepo.validateKeeperFile(fileContent);
        importedEntries = await importRepo.importFromKeeper(fileContent);
      case ImportProvider.lastPass:
        importRepo.validateLastPassFile(fileContent);
        importedEntries = await importRepo.importFromLastPass(fileContent);
      case ImportProvider.opm:
        importRepo.validateOpmFile(fileContent);
        importedEntries = await importRepo.importFromOpm(fileContent);
    }

    for (final newEntry in importedEntries) {
      await vaultRepo.addEntry(newEntry);
    }
  }
}

enum ImportProvider { onePassword, bitwarden, keePass, keeper, lastPass, opm }

extension ImportProviderExtension on ImportProvider {
  String get title {
    switch (this) {
      case ImportProvider.onePassword:
        return "1Password";
      case ImportProvider.bitwarden:
        return "Bitwarden";
      case ImportProvider.keePass:
        return "KeePass";
      case ImportProvider.keeper:
        return "Keeper";
      case ImportProvider.lastPass:
        return "LastPass";
      case ImportProvider.opm:
        return "Open Password Manager";
    }
  }
}
