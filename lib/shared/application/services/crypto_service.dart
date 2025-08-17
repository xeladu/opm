import 'package:open_password_manager/shared/application/services/crypto_service_impl.dart';

class CryptoService {
  final CryptoServiceImpl _crypto;

  CryptoService(this._crypto);

  Future<void> init(String userId, String? password, bool? useBiometric) async {
    await _crypto.init(userId, password, useBiometric);
  }

  Future<String> encrypt(String plainText) async {
    return await _crypto.encrypt(plainText);
  }

  Future<String> decrypt(String plainText) async {
    return await _crypto.decrypt(plainText);
  }
}
