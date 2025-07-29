import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSaltRepositoryImpl implements SaltRepository {
  final SupabaseClient client;
  final String tableName;

  const SupabaseSaltRepositoryImpl({
    required this.client,
    required this.tableName,
  });

  @override
  Future<String?> getUserSalt(String userId) async {
    try {
      final response = await client
          .from(tableName)
          .select('salt')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['salt'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUserSalt(String userId, String salt) async {
    try {
      await client.from(tableName).upsert({'user_id': userId, 'salt': salt});
    } catch (e) {
      print('Error saving user salt: $e');
      rethrow;
    }
  }
}
