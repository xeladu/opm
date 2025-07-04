import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/export_repository.dart';

class FirebaseExportRepositoryImpl implements ExportRepository {
  @override
  Future<void> exportPasswordEntries(List<PasswordEntry> entries) async {
    return;
  }
}
