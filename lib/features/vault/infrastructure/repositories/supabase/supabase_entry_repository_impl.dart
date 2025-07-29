import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEntryRepositoryImpl implements EntryRepository {
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

    await client
        .from(tableName)
        .update(encryptedEntry.toJson())
        .eq('id', entry.id);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await client.from(tableName).delete().eq('id', id);
  }

  @override
  Future<List<VaultEntry>> getAllEntries() async {
    final response = await client.from(tableName).select();
    final entries = (response as List)
        .map((json) => VaultEntry.fromJson(json as Map<String, dynamic>))
        .toList();

    final list = await Future.wait(
      entries.map((entry) => entry.decrypt(cryptoRepo.decrypt)),
    );

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return list;
  }
}
