import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;

class CryptoService {
  final CryptographyRepository cryptoRepo;
  final SaltRepository saltRepo;

  CryptoService({required this.cryptoRepo, required this.saltRepo});

  Future<void> initWithSharedSalt(String password, String userId) async {
    String? existingSalt = await saltRepo.getUserSalt(userId);

    if (existingSalt != null) {
      await cryptoRepo.init(password, sharedSalt: existingSalt);
    } else {
      final newSalt = _generateSalt();
      await saltRepo.saveUserSalt(userId, newSalt);
      await cryptoRepo.init(password, sharedSalt: newSalt);
    }
  }

  String _generateSalt() {
    final random = pc.SecureRandom('Fortuna');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entropy = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      entropy[i] = (timestamp >> (i % 8)) & 0xFF;
    }
    random.seed(pc.KeyParameter(entropy));
    final saltBytes = random.nextBytes(16);
    return base64Encode(saltBytes);
  }
}
