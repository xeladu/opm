import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

class CacheVault {
  final CryptographyRepository cryptoRepo;
  final StorageService storageService;

  CacheVault(this.storageService, this.cryptoRepo);

  Future<void> call(List<VaultEntry> entries) async {
    final encryptedEntries = await Future.wait(
      entries.map((entry) => entry.encrypt(cryptoRepo.encrypt)),
    );
    await storageService.storeOfflineVaultData(encryptedEntries);
  }
}
