import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;

class CryptoHelper {
  static Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    // TODO Check iterations. 1000 seems ok, higher values might be too slow. Need to recreate accounts or migrate stored encryption keys
    const int iterations = 100;
    const int keyLength = 32;

    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    pbkdf2.init(pc.Pbkdf2Parameters(salt, iterations, keyLength));
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
}
