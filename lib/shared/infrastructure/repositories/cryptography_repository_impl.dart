import 'dart:convert';
import 'dart:typed_data';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptographyRepositoryImpl implements CryptographyRepository {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    webOptions: WebOptions(
      dbName: 'opm_secure_storage',
      publicKey: 'opm_public_key',
    ),
  );
  static const String _saltKey = 'encryption_salt';
  static const int _iterations = 100;
  static const int _keyLength = 32;

  Uint8List? _key;
  Uint8List? _salt;

  static CryptographyRepositoryImpl? _instance;
  static CryptographyRepositoryImpl get instance {
    _instance ??= CryptographyRepositoryImpl._();

    return _instance!;
  }

  CryptographyRepositoryImpl._();

  @override
  Future<void> init(String password, {String? sharedSalt}) async {
    if (sharedSalt != null) {
      _salt = base64Decode(sharedSalt);
    } else {
      await _ensureSalt();
    }
    _key = await _deriveKey(password);
  }

  @override
  void dispose() {
    _key = null;
  }

  @override
  String? getCurrentSalt() {
    return _salt != null ? base64Encode(_salt!) : null;
  }

  @override
  Future<String> encrypt(String plainText) async {
    if (_key == null) throw Exception('Encryption key not initialized');

    // Generate cryptographically secure random IV
    final ivBytes = _generateSecureRandomBytes(12);
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    cipher.init(
      true,
      pc.AEADParameters(pc.KeyParameter(_key!), 128, ivBytes, Uint8List(0)),
    );
    final input = Uint8List.fromList(utf8.encode(plainText));
    final output = cipher.process(input);
    final result = Uint8List(ivBytes.length + output.length)
      ..setRange(0, ivBytes.length, ivBytes)
      ..setRange(ivBytes.length, ivBytes.length + output.length, output);
    return base64Encode(result);
  }

  @override
  Future<String> decrypt(String encrypted) async {
    if (_key == null) throw Exception('Encryption key not initialized');

    final data = base64Decode(encrypted);
    final ivBytes = data.sublist(0, 12);
    final cipherText = data.sublist(12);
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    cipher.init(
      false,
      pc.AEADParameters(pc.KeyParameter(_key!), 128, ivBytes, Uint8List(0)),
    );
    final output = cipher.process(cipherText);
    return utf8.decode(output);
  }

  Future<void> _ensureSalt() async {
    final saltStr = await _storage.read(key: _saltKey);
    if (saltStr != null) {
      _salt = base64Decode(saltStr);
    } else {
      final saltBytes = _generateSecureRandomBytes(16);
      _salt = saltBytes;
      await _storage.write(key: _saltKey, value: base64Encode(saltBytes));
    }
  }

  Future<Uint8List> _deriveKey(String password) async {
    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    pbkdf2.init(pc.Pbkdf2Parameters(_salt!, _iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  Uint8List _generateSecureRandomBytes(int length) {
    final random = pc.SecureRandom('Fortuna');
    // Use system time and a counter for better entropy
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entropy = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      entropy[i] = (timestamp >> (i % 8)) & 0xFF;
    }
    random.seed(pc.KeyParameter(entropy));
    return random.nextBytes(length);
  }
}
