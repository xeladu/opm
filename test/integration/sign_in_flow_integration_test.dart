import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/offline_mode_available_provider.dart';
import 'package:open_password_manager/shared/application/services/crypto_service_impl.dart';
import 'package:open_password_manager/shared/presentation/user_menu.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'dart:convert';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/features/auth/domain/entities/offline_auth_data.dart';
import '../helper/test_data_generator.dart';
import '../mocking/mocks.mocks.dart';
import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import '../mocking/fakes.dart';
import '../helper/app_setup.dart';
import '../helper/test_error_suppression.dart';
import '../helper/display_size.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/biometric_auth_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/crypto_utils_repository_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/crypto_service_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/features/settings/domain/entities/settings.dart';

void main() {
  group('Sign-in flow integration', () {
    for (var sizeEntry in DisplaySizes.sizes.entries) {
      final deviceSizeName = sizeEntry.key;
      testWidgets('Test sign in/sign out flow with offline mode ($deviceSizeName)', (tester) async {
        // 1) sign in => offline data is cached
        // 2) sign out
        // 3) simulate no connection
        // 4) sign in with cached offline data
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final mockAuthRepository = MockAuthRepository();
        final mockBiometricAuthRepository = MockBiometricAuthRepository();
        final mockCryptographyRepository = MockCryptographyRepository();
        final mockCryptoUtilsRepository = MockCryptoUtilsRepository();
        final mockStorageService = MockStorageService();
        final mockVaultRepository = MockVaultRepository();

        when(
          mockAuthRepository.signIn(email: anyNamed('email'), password: anyNamed('password')),
        ).thenAnswer((_) async {});
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => OpmUser.empty());
        when(mockAuthRepository.isSessionExpired()).thenAnswer((_) async => true);
        when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));
        when(mockCryptographyRepository.decrypt(any)).thenAnswer((_) => Future.value("decrypted"));

        // Capture saved CryptoUtils so CryptoServiceImpl can generate a real encMek
        CryptoUtils? savedCryptoUtils;
        when(
          mockCryptoUtilsRepository.getCryptoUtils(any),
        ).thenAnswer((_) async => savedCryptoUtils ?? CryptoUtils.empty());
        when(mockCryptoUtilsRepository.saveCryptoUtils(any, any)).thenAnswer((inv) async {
          savedCryptoUtils = inv.positionalArguments[1] as CryptoUtils;
          return Future.value();
        });
        when(mockBiometricAuthRepository.isSupported()).thenAnswer((_) async => false);
        when(mockStorageService.hasMasterKey()).thenAnswer((_) async => false);
        when(mockStorageService.loadOfflineAuthData()).thenAnswer(
          (_) => Future.value(OfflineAuthData(email: "test@example.com", salt: "abc", kdf: {})),
        );
        when(mockStorageService.loadOfflineVaultData()).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );
        when(
          mockStorageService.loadOfflineCryptoUtils(),
        ).thenAnswer((_) => Future.value(savedCryptoUtils));
        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          biometricAuthRepositoryProvider.overrideWithValue(mockBiometricAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          cryptoUtilsRepositoryProvider.overrideWithValue(mockCryptoUtilsRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptoServiceProvider.overrideWithValue(
            CryptoServiceImpl(
              cryptoUtilsRepo: mockCryptoUtilsRepository,
              storageService: mockStorageService,
            ),
          ),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          settingsProvider.overrideWith(() => FakeSettingState(Settings.empty())),
          offlineModeAvailableProvider.overrideWith(() => FakeOfflineModeAvailableState(true)),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        // verify sign in
        verify(
          mockAuthRepository.signIn(email: 'test@example.com', password: 'password123'),
        ).called(1);

        // verify offline storage
        verify(
          mockStorageService.storeOfflineAuthData(
            argThat(
              predicate((a) {
                final OfflineAuthData a2 = a as OfflineAuthData;
                return a2.email == 'test@example.com' && a2.salt.isNotEmpty && a2.kdf != null;
              }),
            ),
          ),
        ).called(1);

        verify(
          mockStorageService.storeOfflineCryptoUtils(
            argThat(
              predicate((cu) {
                final CryptoUtils c = cu as CryptoUtils;
                try {
                  final bytes = base64Decode(c.encryptedMasterKey);
                  return c.salt.isNotEmpty && bytes.length >= 12;
                } catch (_) {
                  return false;
                }
              }),
            ),
          ),
        ).called(1);

        // See VaultListPage after sign in
        expect(find.byType(VaultListPage), findsOneWidget);

        // Sign out
        await tester.tap(find.byType(UserMenu));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Log out'));
        await tester.pumpAndSettle();

        final container = tester.container();
        container.read(noConnectionProvider.notifier).setConnectionState(true);

        // Back to sign in page
        verify(mockAuthRepository.signOut()).called(1);
        expect(find.byType(SignInPage), findsOneWidget);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        verify(mockStorageService.loadOfflineAuthData()).called(1);
        verify(mockStorageService.loadOfflineCryptoUtils()).called(1);

        expect(find.byType(VaultListPage), findsOneWidget);
      });
    }
  });
}
