import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';

import '../../../mocking/mocks.mocks.dart';

void main() {
  group('StorageService', () {
    late MockStorageService storage;

    setUp(() {
      storage = MockStorageService();
    });

    test('Test store and load master key', () async {
      Uint8List? storedKey;

      when(storage.storeBiometricMasterEncryptionKey(any)).thenAnswer((invocation) {
        storedKey = invocation.positionalArguments[0];
        return Future.value();
      });

      when(storage.loadBiometricMasterEncryptionKey()).thenAnswer((_) => Future.value(storedKey));

      final key = Uint8List.fromList(List<int>.generate(32, (i) => i));

      await storage.storeBiometricMasterEncryptionKey(key);
      final loaded = await storage.loadBiometricMasterEncryptionKey();

      expect(loaded, equals(key));
      verify(storage.storeBiometricMasterEncryptionKey(any)).called(1);
      verify(storage.loadBiometricMasterEncryptionKey()).called(1);
    });

    test('Test hasMasterKey false/true', () async {
      bool stored = false;
      when(storage.hasMasterKey()).thenAnswer((_) => Future.value(stored));

      when(storage.storeBiometricMasterEncryptionKey(any)).thenAnswer((_) {
        stored = true;
        return Future.value();
      });

      expect(await storage.hasMasterKey(), isFalse);
      await storage.storeBiometricMasterEncryptionKey(Uint8List.fromList([1, 2, 3]));
      expect(await storage.hasMasterKey(), isTrue);
    });

    test('Test store and load app settings', () async {
      Settings? settings;

      when(storage.storeAppSettings(any)).thenAnswer((invocation) {
        settings = invocation.positionalArguments[0];
        return Future.value();
      });

      when(storage.loadAppSettings()).thenAnswer((_) => Future.value(settings));

      final s = Settings.empty().copyWith(newBiometricAuthEnabled: true);

      await storage.storeAppSettings(s);
      final loaded = await storage.loadAppSettings();

      expect(loaded.biometricAuthEnabled, isTrue);
      verify(storage.storeAppSettings(any)).called(1);
      verify(storage.loadAppSettings()).called(1);
    });
  });
}
