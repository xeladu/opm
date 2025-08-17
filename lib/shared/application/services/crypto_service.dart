import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/exceptions/crypto_service_exception.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;

/// The crypto service manages encryption and decryption of vault data
/// by coordinating key generation, key wrapping, and secure storage.
///
/// On first login, it generates a random master encryption key (MEK),
/// encrypts it with both a password-derived key and a biometric key
/// (if enabled), and stores the encrypted MEKs (cloud and local).
/// For subsequent access, it unlocks the MEK using either the password
/// or biometrics, enabling secure vault operations without exposing
/// sensitive keys or credentials.
class CryptoService {
  final CryptoUtilsRepository cryptoUtilsRepo;
  final StorageService storageService;

  Uint8List _masterEncryptionKey = Uint8List(0);

  CryptoService({required this.cryptoUtilsRepo, required this.storageService});

  /// Initializes the crypto service. After that, encryption and decryption can be used.
  Future<void> init(String userId, String? password, bool? useBiometric) async {
    if (password == null && (useBiometric == null || useBiometric == false)) {
      throw CryptoServiceException("Either 'password' or 'biometricKey' needs to be set");
    }

    final cryptoUtils = await cryptoUtilsRepo.getCryptoUtils(userId);

    if (password != null) {
      final salt = cryptoUtils.salt.isNotEmpty ? base64Decode(cryptoUtils.salt) : _generateSalt();
      await _initWithPassword(userId, password, salt);
    }

    if (useBiometric == true) {
      await _initWithBiometricKey();
    }
  }

  Future<String> encrypt(String plainText) async {
    return await _encryptInternal(_masterEncryptionKey, plainText);
  }

  Future<String> decrypt(String plainText) async {
    return await _decryptInternal(_masterEncryptionKey, plainText);
  }

  Future<void> _initWithPassword(String userId, String password, Uint8List salt) async {
    // derive key from password and salt and create a new
    // shared master encryption key or use an existing one.
    final derivationKey = await _deriveKey(password, salt);

    final cryptoUtils = await cryptoUtilsRepo.getCryptoUtils(userId);

    // get or generate shared encrypted master encryption key
    if (cryptoUtils.encryptedMasterKey.isEmpty) {
      final newMasterEncryptionKey = _generateMasterEncryptionKey();
      final newEncryptedMasterEncryptionKey = await _encryptInternal(
        derivationKey,
        base64Encode(newMasterEncryptionKey),
      );

      await cryptoUtilsRepo.saveCryptoUtils(
        userId,
        cryptoUtils.copyWith(newSalt: base64Encode(salt), encMek: newEncryptedMasterEncryptionKey),
      );

      // store the raw generated master encryption key (not the encrypted blob)
      _masterEncryptionKey = newMasterEncryptionKey;
    } else {
      // decrypt the existing key
      _masterEncryptionKey = base64Decode(
        await _decryptInternal(derivationKey, cryptoUtils.encryptedMasterKey),
      );
    }
  }

  Future<void> _initWithBiometricKey() async {
    final loadedKey = await storageService.loadBiometricMasterEncryptionKey();
    if (loadedKey.isEmpty) {
      await storageService.storeBiometricMasterEncryptionKey(_masterEncryptionKey);
    } else {
      _masterEncryptionKey = loadedKey;
    }

    _masterEncryptionKey = loadedKey;
  }

  Future<String> _encryptInternal(Uint8List key, String plainText) async {
    final ivBytes = _generateSecureRandomBytes(12);
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    cipher.init(true, pc.AEADParameters(pc.KeyParameter(key), 128, ivBytes, Uint8List(0)));
    final input = Uint8List.fromList(utf8.encode(plainText));
    final output = cipher.process(input);
    final result = Uint8List(ivBytes.length + output.length)
      ..setRange(0, ivBytes.length, ivBytes)
      ..setRange(ivBytes.length, ivBytes.length + output.length, output);
    return base64Encode(result);
  }

  Future<String> _decryptInternal(Uint8List key, String encrypted) async {
    final data = base64Decode(encrypted);
    final ivBytes = data.sublist(0, 12);
    final cipherText = data.sublist(12);
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    cipher.init(false, pc.AEADParameters(pc.KeyParameter(key), 128, ivBytes, Uint8List(0)));
    final output = cipher.process(cipherText);
    return utf8.decode(output);
  }

  static Uint8List _generateSalt() {
    return _generateSecureRandomBytes(32);
  }

  static Uint8List _generateMasterEncryptionKey() {
    return _generateSecureRandomBytes(32);
  }

  static Future<Uint8List> _deriveKey(String password, Uint8List salt) async {
    const int iterations = 100;
    const int keyLength = 32;

    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    pbkdf2.init(pc.Pbkdf2Parameters(salt, iterations, keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  static Uint8List _generateSecureRandomBytes(int length) {
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
