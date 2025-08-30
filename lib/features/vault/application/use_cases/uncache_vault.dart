import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';

class UncacheVault {
  final CryptographyRepository cryptoRepo;
  final StorageService storageService;

  UncacheVault(this.storageService, this.cryptoRepo);

  Future<List<VaultEntry>> call() async {
    final entries = await storageService.loadOfflineVaultData();
    final decryptedEntries = await Future.wait(
      entries.map((entry) => entry.decrypt(cryptoRepo.decrypt)),
    );

    return decryptedEntries;
  }
}
