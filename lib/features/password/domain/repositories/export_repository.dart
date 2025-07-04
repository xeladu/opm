import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';

abstract class ExportRepository {
  Future<void> exportPasswordEntries(List<PasswordEntry> entries);
}
