import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

class GetAllEntries {
  final VaultRepository repository;

  GetAllEntries(this.repository);

  Future<List<VaultEntry>> call({Function(String)? onUpdate}) async {
    return await repository.getAllEntries(onUpdate: onUpdate);
  }
}
