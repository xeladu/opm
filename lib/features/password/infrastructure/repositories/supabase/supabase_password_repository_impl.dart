import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePasswordRepositoryImpl implements PasswordRepository {
  final SupabaseClient client;
  final String databaseName;
  final CryptographyRepository cryptoRepo;

  SupabasePasswordRepositoryImpl({
    required this.client,
    required this.databaseName,
    required this.cryptoRepo,
  });

  @override
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await client.from(databaseName).insert(encryptedEntry.toJson());
  }

  @override
  Future<void> editPasswordEntry(PasswordEntry entry) async {
    final encryptedEntry = await entry.encrypt(cryptoRepo.encrypt);

    await client
        .from(databaseName)
        .update(encryptedEntry.toJson())
        .eq('id', entry.id);
  }

  @override
  Future<void> deletePasswordEntry(String id) async {
    await client.from(databaseName).delete().eq('id', id);
  }

  @override
  Future<List<PasswordEntry>> getAllPasswordEntries() async {
    final response = await client.from(databaseName).select();
    final entries = (response as List)
        .map((json) => PasswordEntry.fromJson(json as Map<String, dynamic>))
        .toList();

    return Future.wait(
      entries.map((entry) => entry.decrypt(cryptoRepo.decrypt)),
    );
  }
}
