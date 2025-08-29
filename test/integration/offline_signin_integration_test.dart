import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/shared/application/services/crypto_service_impl.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';

import '../mocking/mocks.mocks.dart';

void main() {
  group('Offline sign-in integration', () {
    const userId = 'user-integ';
    const password = 'test-password-123';

    test('exported offline crypto utils can be used to init offline', () async {
      final cryptoUtilsRepo = MockCryptoUtilsRepository();
      final storageService = MockStorageService();

      // Start with no crypto utils stored remotely
      when(cryptoUtilsRepo.getCryptoUtils(userId)).thenAnswer((_) async => CryptoUtils.empty());

      final service = CryptoServiceImpl(cryptoUtilsRepo: cryptoUtilsRepo, storageService: storageService);

      // Perform normal init which will generate and save an encrypted MEK
      await service.init(userId, password, null);

      // Export offline crypto utils (salt + encMek)
      final offline = await service.exportOfflineCryptoUtils(password);

      expect(offline.salt.isNotEmpty, isTrue);
      expect(offline.encryptedMasterKey.isNotEmpty, isTrue);

      // Create a new service instance that will initialize from the offline blob
      final serviceOffline = CryptoServiceImpl(cryptoUtilsRepo: cryptoUtilsRepo, storageService: storageService);

      // Initialize using the offline crypto utils
      await serviceOffline.initWithOfflineCryptoUtils(offline, password);

      // Ensure encryption/decryption works after offline init
      final cipher = await serviceOffline.encrypt('offline-test');
      final plain = await serviceOffline.decrypt(cipher);
      expect(plain, 'offline-test');
    });
  });
}
