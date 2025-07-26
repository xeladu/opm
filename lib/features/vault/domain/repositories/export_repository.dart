import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

abstract class ExportRepository {
  Future<void> exportPasswordEntries(List<VaultEntry> entries);
}
