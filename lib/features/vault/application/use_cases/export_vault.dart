import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';

class ExportVault {
  final ExportRepository exportRepo;
  final EntryRepository passwordRepo;

  ExportVault(this.passwordRepo, this.exportRepo);

  Future<void> call() async {
    final allPasswords = await passwordRepo.getAllEntries();
    await exportRepo.exportPasswordEntries(allPasswords);
  }
}
