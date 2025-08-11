import 'package:open_password_manager/shared/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

class CryptographyRepositoryImpl implements CryptographyRepository {
  final CryptoService cryptoService;

  CryptographyRepositoryImpl(this.cryptoService);

  @override
  Future<String> decrypt(String plainText) {
    return cryptoService.decrypt(plainText);
  }

  @override
  Future<String> encrypt(String plainText) {
    return cryptoService.encrypt(plainText);
  }
}
