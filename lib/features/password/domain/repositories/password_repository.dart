import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';

abstract class PasswordRepository {
  Future<void> addPasswordEntry(PasswordEntry entry);
  Future<void> editPasswordEntry(PasswordEntry entry);
  Future<void> deletePasswordEntry(String id);
  Future<List<PasswordEntry>> getAllPasswordEntries();
}
