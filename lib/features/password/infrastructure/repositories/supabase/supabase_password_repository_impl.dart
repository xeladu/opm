import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePasswordRepositoryImpl implements PasswordRepository {
  final SupabaseClient client;
  final String databaseName;

  SupabasePasswordRepositoryImpl({
    required this.client,
    required this.databaseName,
  });

  @override
  Future<void> addPasswordEntry(PasswordEntry entry) async {
    await client.from(databaseName).insert(entry.toJson());
  }

  @override
  Future<void> editPasswordEntry(PasswordEntry entry) async {
    await client.from(databaseName).update(entry.toJson()).eq('id', entry.id);
  }

  @override
  Future<void> deletePasswordEntry(String id) async {
    await client.from(databaseName).delete().eq('id', id);
  }

  @override
  Future<List<PasswordEntry>> getAllPasswordEntries() async {
    final response = await client.from(databaseName).select();
    return (response as List)
        .map((json) => PasswordEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
