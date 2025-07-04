import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';

class GetAllPasswordEntries {
  final PasswordRepository repository;

  GetAllPasswordEntries(this.repository);

  Future<List<PasswordEntry>> call() async {
    return await repository.getAllPasswordEntries();
  }
}
