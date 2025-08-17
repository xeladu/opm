import 'dart:typed_data';

import 'package:open_password_manager/features/settings/domain/entities/settings.dart';
import 'package:open_password_manager/shared/application/services/storage_service_impl.dart';

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
}
