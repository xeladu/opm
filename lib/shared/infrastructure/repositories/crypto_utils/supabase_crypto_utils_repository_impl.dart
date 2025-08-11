import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCryptoUtilsRepositoryImpl implements CryptoUtilsRepository {
  final SupabaseClient client;
  final String tableName;

  const SupabaseCryptoUtilsRepositoryImpl({required this.client, required this.tableName});

  @override
  Future<CryptoUtils> getCryptoUtils(String userId) async {
    try {
      final response = await client
          .from(tableName)
          .select('salt')
          .eq('user_id', userId)
          .maybeSingle();

      return response == null ? CryptoUtils.empty() : CryptoUtils.fromJson(response);
    } catch (e) {
      return CryptoUtils.empty();
    }
  }

  @override
  Future<void> saveCryptoUtils(String userId, CryptoUtils utils) async {
    try {
      await client.from(tableName).upsert({
        'user_id': userId,
        'salt': utils.salt,
        'encMek': utils.encryptedMasterKey,
      });
    } catch (e) {
      rethrow;
    }
  }
}
