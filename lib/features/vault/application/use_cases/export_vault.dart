import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';

class ExportVault {
  final ExportRepository exportRepo;
  final VaultRepository vaultRepo;

  ExportVault(this.vaultRepo, this.exportRepo);

  Future<void> call(ExportOption option) async {
    final allPasswords = await vaultRepo.getAllEntries();
    switch (option) {
      case ExportOption.json:
        await exportRepo.exportPasswordEntriesJson(allPasswords);
      case ExportOption.csv:
        await exportRepo.exportPasswordEntriesCsv(allPasswords);
    }
  }
}

enum ExportOption { json, csv }
