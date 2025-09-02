import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;

class CryptoHelper {
  static final int _iterations = 10000;
  static final int _keyLength = 32;
  static final int _version = 1;

  static Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    pbkdf2.init(pc.Pbkdf2Parameters(salt, _iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  static Uint8List generateSecureRandomBytes(int length) {
    final random = pc.SecureRandom('Fortuna');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entropy = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      entropy[i] = (timestamp >> (i % 8)) & 0xFF;
    }
    random.seed(pc.KeyParameter(entropy));
    return random.nextBytes(length);
  }

  /// Returns the KDF parameters used by `deriveKey` so callers can persist
  /// them alongside encrypted blobs for migration/versioning.
  static Map<String, dynamic> kdfParams() {
    return {
      'iters': _iterations,
      'dkLen': _keyLength,
      'version': _version,
    };
  }
}
