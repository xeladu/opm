import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

abstract class CryptoUtilsRepository {
  Future<CryptoUtils> getCryptoUtils(String userId);
  Future<void> saveCryptoUtils(String userId, CryptoUtils utils);
}
