import 'package:open_password_manager/features/password/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';

class ExportPasswordEntries {
  final ExportRepository exportRepo;
  final PasswordRepository passwordRepo;

  ExportPasswordEntries(this.passwordRepo, this.exportRepo);

  Future<void> call() async {
    final allPasswords = await passwordRepo.getAllPasswordEntries();
    await exportRepo.exportPasswordEntries(allPasswords);
  }
}
