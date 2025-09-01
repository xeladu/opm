import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_password_manager/features/auth/domain/entities/offline_auth_data.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

class StorageServiceImpl implements StorageService {
  // TODO allow multi user
  static AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  static IOSOptions _getIosOptions() =>
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions(), iOptions: _getIosOptions());

  final _masterEncryptionKey = "masterKey";
  final _settingsKey = "settings";
  final _offlineAuthDataKey = "offline_auth";
  final _offlineVaultDataKey = "offline_vault";
  final _offlineCryptoUtilsKey = "offline_crypto_utils";

  @override
  Future<bool> hasMasterKey() async {
    return await _storage.containsKey(key: _masterEncryptionKey);
  }

  @override
  Future<void> storeBiometricMasterEncryptionKey(Uint8List key) async {
    await _storage.write(key: _masterEncryptionKey, value: base64Encode(key));
  }

  @override
  Future<Uint8List> loadBiometricMasterEncryptionKey() async {
    final storageValue = await _storage.read(key: _masterEncryptionKey);
    return storageValue == null ? Uint8List(0) : base64Decode(storageValue);
  }

  @override
  Future<void> storeAppSettings(Settings settings) async {
    await _storage.write(key: _settingsKey, value: jsonEncode(settings.toJson()));
  }

  @override
  Future<Settings> loadAppSettings() async {
    final storageValue = await _storage.read(key: _settingsKey);
    return storageValue == null ? Settings.empty() : Settings.fromJson(jsonDecode(storageValue));
  }

  @override
  Future<void> storeOfflineAuthData(OfflineAuthData data) async {
    await _storage.write(key: _offlineAuthDataKey, value: jsonEncode(data.toJson()));
  }

  @override
  Future<OfflineAuthData> loadOfflineAuthData() async {
    final storageValue = await _storage.read(key: _offlineAuthDataKey);
    return storageValue == null
        ? OfflineAuthData.empty()
        : OfflineAuthData.fromJson(jsonDecode(storageValue));
  }

  @override
  Future<void> storeOfflineVaultData(List<VaultEntry> data) async {
    await _storage.write(
      key: _offlineVaultDataKey,
      value: jsonEncode(data.map((entry) => entry.toJson()).toList()),
    );
  }

  @override
  Future<List<VaultEntry>> loadOfflineVaultData() async {
    final storageValue = await _storage.read(key: _offlineVaultDataKey);
    return storageValue == null
        ? []
        : (jsonDecode(storageValue) as List).map((item) => VaultEntry.fromJson(item)).toList();
  }

  @override
  Future<void> storeOfflineCryptoUtils(CryptoUtils data) async {
    await _storage.write(key: _offlineCryptoUtilsKey, value: jsonEncode(data.toJson()));
  }

  @override
  Future<CryptoUtils> loadOfflineCryptoUtils() async {
    final storageValue = await _storage.read(key: _offlineCryptoUtilsKey);
    return storageValue == null
        ? CryptoUtils.empty()
        : CryptoUtils.fromJson(jsonDecode(storageValue));
  }
}
