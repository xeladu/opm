import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';

class FirebasePasswordRepositoryImpl implements PasswordRepository {
  @override
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    return;
  }

  @override
  Future<void> editPasswordEntry(PasswordEntry entry) async {
    return;
  }

  @override
  Future<void> deletePasswordEntry(String id) async {
    return;
  }

  @override
  Future<List<PasswordEntry>> getAllPasswordEntries() async {
    return [];
  }
}
