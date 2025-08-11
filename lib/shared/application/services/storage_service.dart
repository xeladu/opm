import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  static IOSOptions _getIosOptions() =>
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions(), iOptions: _getIosOptions());

  final _masterEncryptionKey = "masterKey";

  Future<bool> hasMasterKey() async {
    return await _storage.containsKey(key: _masterEncryptionKey);
  }

  Future<void> storeBiometricMasterEncryptionKey(Uint8List key) async {
    await _storage.write(key: _masterEncryptionKey, value: base64Encode(key));
  }

  Future<Uint8List> loadBiometricMasterEncryptionKey() async {
    final storageValue = await _storage.read(key: _masterEncryptionKey);
    return storageValue == null ? Uint8List(0) : base64Decode(storageValue);
  }
}
