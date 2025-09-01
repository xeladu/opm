import 'dart:typed_data';

import 'package:open_password_manager/features/auth/domain/entities/offline_auth_data.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

abstract class StorageService {
  Future<bool> hasMasterKey();

  Future<void> storeBiometricMasterEncryptionKey(Uint8List key);

  Future<Uint8List> loadBiometricMasterEncryptionKey();

  Future<void> storeAppSettings(Settings settings);

  Future<Settings> loadAppSettings();

  Future<void> storeOfflineAuthData(OfflineAuthData data);

  Future<OfflineAuthData> loadOfflineAuthData();

  Future<void> storeOfflineVaultData(List<VaultEntry> data);

  Future<List<VaultEntry>> loadOfflineVaultData();

  Future<void> storeOfflineCryptoUtils(CryptoUtils data);

  Future<CryptoUtils> loadOfflineCryptoUtils();
}
