import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/shared/application/services/crypto_service_impl.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  group('CryptoService', () {
    const userId = 'user-1';
    const password = 'correct-horse-battery-staple';

    test('Test init with password generates and saves new MEK and can encrypt/decrypt', () async {
      final cryptoUtilsRepo = MockCryptoUtilsRepository();
      final storageService = MockStorageService();

      when(cryptoUtilsRepo.getCryptoUtils(userId)).thenAnswer((_) async => CryptoUtils.empty());

      CryptoUtils? saved;
      when(cryptoUtilsRepo.saveCryptoUtils(any, any)).thenAnswer((inv) async {
        saved = inv.positionalArguments[1] as CryptoUtils;
        return Future<void>.value();
      });

      final service = CryptoServiceImpl(
        cryptoUtilsRepo: cryptoUtilsRepo,
        storageService: storageService,
      );

      await service.init(userId, password, null);

      // ensure we saved crypto utils with non-empty encrypted MEK
      expect(saved, isNotNull);
      expect(saved!.encryptedMasterKey.isNotEmpty, isTrue);

      // can encrypt and decrypt
      final cipher = await service.encrypt('hello world');
      final plain = await service.decrypt(cipher);
      expect(plain, 'hello world');
    });

    test('Test init with existing encrypted MEK decrypts and works across instances', () async {
      final cryptoUtilsRepo1 = MockCryptoUtilsRepository();
      final cryptoUtilsRepo2 = MockCryptoUtilsRepository();
      final storageService = MockStorageService();

      when(cryptoUtilsRepo1.getCryptoUtils(userId)).thenAnswer((_) async => CryptoUtils.empty());

      CryptoUtils? saved;
      when(cryptoUtilsRepo1.saveCryptoUtils(any, any)).thenAnswer((inv) async {
        saved = inv.positionalArguments[1] as CryptoUtils;
        return Future<void>.value();
      });

      final service1 = CryptoServiceImpl(
        cryptoUtilsRepo: cryptoUtilsRepo1,
        storageService: storageService,
      );
      await service1.init(userId, password, null);

      expect(saved, isNotNull);

      // Now create a second service which will load the saved encrypted MEK
      when(cryptoUtilsRepo2.getCryptoUtils(userId)).thenAnswer((_) async => saved!);
      final service2 = CryptoServiceImpl(
        cryptoUtilsRepo: cryptoUtilsRepo2,
        storageService: storageService,
      );
      await service2.init(userId, password, null);

      final cipher = await service2.encrypt('roundtrip');
      final plain = await service2.decrypt(cipher);
      expect(plain, 'roundtrip');
    });

    test('Test biometric init stores MEK when not present and loads when present', () async {
      final cryptoUtilsRepo = MockCryptoUtilsRepository();
      final storageService = MockStorageService();

      when(cryptoUtilsRepo.getCryptoUtils(userId)).thenAnswer((_) async => CryptoUtils.empty());

      when(storageService.loadBiometricMasterEncryptionKey()).thenAnswer((_) async => Uint8List(0));
      when(storageService.storeBiometricMasterEncryptionKey(any)).thenAnswer((_) async {});

      final service = CryptoServiceImpl(
        cryptoUtilsRepo: cryptoUtilsRepo,
        storageService: storageService,
      );
      await service.init(userId, password, null);

      // now call biometric init which should call storeBiometricMasterEncryptionKey
      await service.init(userId, null, true);
      verify(storageService.storeBiometricMasterEncryptionKey(any)).called(1);

      // simulate stored key present: return a valid base64-encoded key
      when(
        storageService.loadBiometricMasterEncryptionKey(),
      ).thenAnswer((_) async => Uint8List.fromList(List<int>.filled(32, 1)));

      // calling biometric init should load and not throw
      await service.init(userId, null, true);
    });
  });
}
