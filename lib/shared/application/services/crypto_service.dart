import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

abstract class CryptoService {
  Future<void> init(String userId, String? password, bool? useBiometric);

  Future<CryptoUtils> exportOfflineCryptoUtils(String password);

  Future<void> initWithOfflineCryptoUtils(CryptoUtils cryptoUtils, String password);

  Future<String> encrypt(String plainText);

  Future<String> decrypt(String plainText);
}
