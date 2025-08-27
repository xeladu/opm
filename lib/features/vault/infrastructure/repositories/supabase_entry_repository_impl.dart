import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/exceptions/database_exception.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEntryRepositoryImpl implements VaultRepository {
  final SupabaseClient client;
  final String tableName;
  final CryptographyRepository cryptoRepo;

  SupabaseEntryRepositoryImpl({
    required this.client,
    required this.tableName,
    required this.cryptoRepo,
  });

  @override
  Future<void> addEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await client.from(tableName).insert(encryptedEntry.toJson());
  }

  @override
  Future<void> editEntry(VaultEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await client.from(tableName).update(encryptedEntry.toJson()).eq('id', entry.id);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await client.from(tableName).delete().eq('id', id);
  }

  @override
  Future<List<VaultEntry>> getAllEntries({
    Function(String info, double? progress)? onUpdate,
  }) async {
    final response = await client.from(tableName).select();
    final entries = (response as List)
        .map((json) => VaultEntry.fromJson(json as Map<String, dynamic>))
        .toList();

    if (onUpdate != null) onUpdate("${entries.length} entries loaded ...", null);

    final list = <VaultEntry>[];
    for (var i = 0; i < entries.length; i++) {
      list.add(await entries[i].decrypt(cryptoRepo.decrypt));

      if (onUpdate != null) {
        onUpdate("Decrypting entry $i of ${entries.length} ...", i / entries.length);
      }

      await Future.delayed(Duration.zero);
    }

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (onUpdate != null) {
      onUpdate("Sorting data ...", null);
    }

    return list;
  }
  
  @override
  Future<void> deleteAllEntries() {
    final user = client.auth.currentUser;
    if (user == null) {
      throw DatabaseException(message: "User not authenticated!");
    }

    return client.from(tableName).delete().eq('user_id', user.id);
  }
}
