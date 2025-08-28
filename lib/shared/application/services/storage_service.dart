import 'dart:typed_data';

import 'package:open_password_manager/features/auth/domain/entities/offline_auth_data.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/application/services/storage_service_impl.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

class StorageService {
  final StorageServiceImpl _storageService;

  StorageService(this._storageService);

  Future<bool> hasMasterKey() async {
    return await _storageService.hasMasterKey();
  }

  Future<void> storeBiometricMasterEncryptionKey(Uint8List key) async {
    return await _storageService.storeBiometricMasterEncryptionKey(key);
  }

  Future<Uint8List> loadBiometricMasterEncryptionKey() async {
    return await _storageService.loadBiometricMasterEncryptionKey();
  }

  Future<void> storeAppSettings(Settings settings) async {
    return await _storageService.storeAppSettings(settings);
  }

  Future<Settings> loadAppSettings() async {
    return await _storageService.loadAppSettings();
  }

  Future<void> storeOfflineAuthData(OfflineAuthData data) async {
    return await _storageService.storeOfflineAuthData(data);
  }

  Future<OfflineAuthData> loadOfflineAuthData() async {
    return await _storageService.loadOfflineAuthData();
  }

  Future<void> storeOfflineVaultData(List<VaultEntry> data) async {
    return await _storageService.storeOfflineVaultData(data);
  }

  Future<List<VaultEntry>> loadOfflineVaultData() async {
    return await _storageService.loadOfflineVaultData();
  }

  Future<void> storeOfflineCryptoUtils(CryptoUtils data) async {
    return await _storageService.storeOfflineCryptoUtils(data);
  }

  Future<CryptoUtils> loadOfflineCryptoUtils() async {
    return await _storageService.loadOfflineCryptoUtils();
  }
}
