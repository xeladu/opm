import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';

class DeleteEntry {
  final EntryRepository repository;

  DeleteEntry(this.repository);

  Future<void> call(String id) async {
    await repository.deleteEntry(id);
  }
}
