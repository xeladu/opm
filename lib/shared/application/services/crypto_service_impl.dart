import 'package:open_password_manager/shared/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/domain/exceptions/crypto_service_exception.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/utils/crypto_helper.dart';
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
class CryptoServiceImpl implements CryptoService {
  final CryptoUtilsRepository cryptoUtilsRepo;
  final StorageService storageService;

  Uint8List _masterEncryptionKey = Uint8List(0);
  Uint8List? _lastSalt;

  CryptoServiceImpl({required this.cryptoUtilsRepo, required this.storageService});

  /// Initializes the crypto service. After that, encryption and decryption can be used.
  @override
  Future<void> init(String userId, String? password, bool? useBiometric) async {
    if (password == null && (useBiometric == null || useBiometric == false)) {
      throw CryptoServiceException("Either 'password' or 'biometricKey' needs to be set");
    }

    final cryptoUtils = await cryptoUtilsRepo.getCryptoUtils(userId);

    if (password != null) {
      final salt = cryptoUtils.salt.isNotEmpty ? base64Decode(cryptoUtils.salt) : _randomBytes(32);
      await _initWithPassword(userId, password, salt);
    }

    if (useBiometric == true) {
      await _initWithBiometricKey();
    }
  }

  @override
  Future<String> encrypt(String plainText) async {
    return await _encryptInternal(_masterEncryptionKey, plainText);
  }

  @override
  Future<String> decrypt(String plainText) async {
    return await _decryptInternal(_masterEncryptionKey, plainText);
  }

  Future<void> _initWithPassword(String userId, String password, Uint8List salt) async {
    // derive key from password and salt and create a new
    // shared master encryption key or use an existing one.
    _lastSalt = salt;
    final derivationKey = await CryptoHelper.deriveKey(password, salt);

    final cryptoUtils = await cryptoUtilsRepo.getCryptoUtils(userId);

    // get or generate shared encrypted master encryption key
    if (cryptoUtils.encryptedMasterKey.isEmpty) {
      final newMasterEncryptionKey = _randomBytes(32);
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

  /// Exports a versioned [CryptoUtils] object suitable for storing locally
  /// so the app can later initialize the crypto stack while offline.
  /// This derives a key from [password] using the last used salt and
  /// returns the encrypted master encryption key (encMek) encrypted with
  /// the derived key.
  @override
  Future<CryptoUtils> exportOfflineCryptoUtils(String password) async {
    if (_lastSalt == null || _lastSalt!.isEmpty) {
      throw CryptoServiceException('No salt available to export offline crypto utils');
    }

    final derivationKey = await CryptoHelper.deriveKey(password, _lastSalt!);
    final encMek = await _encryptInternal(derivationKey, base64Encode(_masterEncryptionKey));

    return CryptoUtils(salt: base64Encode(_lastSalt!), encryptedMasterKey: encMek);
  }

  /// Initialize crypto service using an externally provided [cryptoUtils]
  /// blob (for example read from secure local storage) instead of fetching
  /// it from remote storage. This enables offline initialization.
  @override
  Future<void> initWithOfflineCryptoUtils(CryptoUtils cryptoUtils, String password) async {
    final salt = cryptoUtils.salt.isNotEmpty ? base64Decode(cryptoUtils.salt) : _randomBytes(32);
    _lastSalt = salt;
    final derivationKey = await CryptoHelper.deriveKey(password, salt);

    if (cryptoUtils.encryptedMasterKey.isEmpty) {
      // No encMek present in the offline blob; can't initialize offline.
      throw CryptoServiceException('No encrypted MEK found in offline crypto utils');
    }

    _masterEncryptionKey = base64Decode(
      await _decryptInternal(derivationKey, cryptoUtils.encryptedMasterKey),
    );

    return;
  }

  Future<void> _initWithBiometricKey() async {
    final loadedKey = await storageService.loadBiometricMasterEncryptionKey();
    if (loadedKey.isEmpty) {
      await storageService.storeBiometricMasterEncryptionKey(_masterEncryptionKey);
    } else {
      _masterEncryptionKey = loadedKey;
    }
  }

  Future<String> _encryptInternal(Uint8List key, String plainText) async {
    final ivBytes = _randomBytes(12);
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

  static Uint8List _randomBytes(int length) => CryptoHelper.generateSecureRandomBytes(length);
}
