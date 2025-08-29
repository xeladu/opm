import 'package:open_password_manager/shared/application/services/crypto_service_impl.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

class CryptoService {
  final CryptoServiceImpl _crypto;

  CryptoService(this._crypto);

  Future<void> init(String userId, String? password, bool? useBiometric) async {
    await _crypto.init(userId, password, useBiometric);
  }

  Future<CryptoUtils> exportOfflineCryptoUtils(String password) async {
    return await _crypto.exportOfflineCryptoUtils(password);
  }

  Future<void> initWithOfflineCryptoUtils(CryptoUtils cryptoUtils, String password) async {
    return await _crypto.initWithOfflineCryptoUtils(cryptoUtils, password);
  }

  Future<String> encrypt(String plainText) async {
    return await _crypto.encrypt(plainText);
  }

  Future<String> decrypt(String plainText) async {
    return await _crypto.decrypt(plainText);
  }
}
