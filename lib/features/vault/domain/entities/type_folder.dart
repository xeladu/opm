import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';

class TypeFolder {
  final VaultEntryType type;
  final int entryCount;

  TypeFolder({required this.type, required this.entryCount});
}
