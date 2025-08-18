import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/biometric_auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/shared/application/providers/crypto_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/crypto_utils_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../helper/test_error_suppression.dart';
import '../../../helper/display_size.dart';
import 'package:open_password_manager/features/auth/presentation/pages/create_account_page.dart';

import '../../../mocking/mocks.mocks.dart';

void main() {
  for (var sizeEntry in DisplaySizes.sizes.entries) {
    group('SignInPage', () {
      late MockAuthRepository mockAuthRepository;
      late MockBiometricAuthRepository mockBiometricAuthRepository;
      late MockCryptographyRepository mockCryptographyRepository;
      late MockStorageService mockStorageService;
      late MockCryptoUtilsRepository mockCryptoUtilsRepository;
      late MockCryptoService mockCryptoService;
      late MockVaultRepository mockVaultRepository;

      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockAuthRepository = MockAuthRepository();
        mockBiometricAuthRepository = MockBiometricAuthRepository();
        mockCryptographyRepository = MockCryptographyRepository();
        mockStorageService = MockStorageService();
        mockCryptoUtilsRepository = MockCryptoUtilsRepository();
        mockCryptoService = MockCryptoService();
        mockVaultRepository = MockVaultRepository();
      });

      testWidgets('Test default elements ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        expect(
          find.byType(SignInPageMobile),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(SignInPageDesktop),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsNothing : findsOneWidget,
        );
      });

      testWidgets('Test navigation to create account page ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.tap(find.byType(SecondaryButton));
        await tester.pumpAndSettle();

        expect(find.byType(CreateAccountPage), findsOneWidget);
      });

      testWidgets('Test empty email ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), '');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Please enter a value'), findsOneWidget);
      });

      testWidgets('Test empty password ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), '');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Please enter a value'), findsOneWidget);
      });

      testWidgets('Test invalid email ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'invalid-email');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Invalid email'), findsOneWidget);
      });

      testWidgets('Test valid sign in ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(
          mockAuthRepository.signIn(email: anyNamed('email'), password: anyNamed('password')),
        ).thenAnswer((_) async {});
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => Future.value(OpmUser.empty()));
        when(mockAuthRepository.isSessionExpired()).thenAnswer((_) => Future.value(true));

        when(
          mockCryptoUtilsRepository.getCryptoUtils(any),
        ).thenAnswer((_) => Future.value(CryptoUtils.empty()));

        when(mockBiometricAuthRepository.isSupported()).thenAnswer((_) => Future.value(false));

        when(mockStorageService.hasMasterKey()).thenAnswer((_) => Future.value(false));

        when(mockCryptoService.init(any, any, any)).thenAnswer((_) => Future.value());

        when(
          mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate')),
        ).thenAnswer((_) => Future.value([]));

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          biometricAuthRepositoryProvider.overrideWithValue(mockBiometricAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          cryptoUtilsRepositoryProvider.overrideWithValue(mockCryptoUtilsRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptoServiceProvider.overrideWithValue(mockCryptoService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        verify(
          mockAuthRepository.signIn(email: 'test@example.com', password: 'password123'),
        ).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verify(mockCryptoService.init(any, any, false)).called(1);
        expect(find.byType(ShadToast), findsOneWidget);
        expect(find.textContaining("Sign in successful"), findsOneWidget);
        expect(find.byType(VaultListPage), findsOneWidget);
      });

      testWidgets('Test failed biometric sign in ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(mockAuthRepository.isSessionExpired()).thenAnswer((_) => Future.value(false));
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => Future.value(OpmUser.empty()));

        when(
          mockCryptoUtilsRepository.getCryptoUtils(any),
        ).thenAnswer((_) => Future.value(CryptoUtils.empty()));

        when(mockBiometricAuthRepository.isSupported()).thenAnswer((_) => Future.value(true));
        when(mockStorageService.hasMasterKey()).thenAnswer((_) => Future.value(true));
        when(mockBiometricAuthRepository.authenticate()).thenThrow(Exception("error"));

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          biometricAuthRepositoryProvider.overrideWithValue(mockBiometricAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          cryptoUtilsRepositoryProvider.overrideWithValue(mockCryptoUtilsRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ]);

        // wait for biometric auth
        await tester.pump(Duration(milliseconds: 300));

        verifyNever(mockAuthRepository.signIn(email: 'a', password: 'b'));
        verifyNever(mockAuthRepository.getCurrentUser());
        verify(mockBiometricAuthRepository.isSupported()).called(1);
        verify(mockStorageService.hasMasterKey()).called(1);
        verify(mockBiometricAuthRepository.authenticate()).called(1);
        verifyNever(mockCryptoService.init(any, any, any));
        expect(find.byType(ShadToast), findsOneWidget);
        expect(find.textContaining("Biometric authentication failed"), findsOneWidget);
        expect(find.byType(SignInPage), findsOneWidget);
      });

      testWidgets('Test valid biometric sign in ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(mockAuthRepository.isSessionExpired()).thenAnswer((_) => Future.value(false));
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => Future.value(OpmUser.empty()));

        when(
          mockCryptoUtilsRepository.getCryptoUtils(any),
        ).thenAnswer((_) => Future.value(CryptoUtils.empty()));

        when(mockBiometricAuthRepository.isSupported()).thenAnswer((_) => Future.value(true));
        when(mockBiometricAuthRepository.authenticate()).thenAnswer((_) => Future.value(true));

        when(mockStorageService.hasMasterKey()).thenAnswer((_) => Future.value(true));

        when(mockCryptoService.init(any, any, any)).thenAnswer((_) => Future.value());

        when(
          mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate')),
        ).thenAnswer((_) => Future.value([]));

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          biometricAuthRepositoryProvider.overrideWithValue(mockBiometricAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          cryptoServiceProvider.overrideWithValue(mockCryptoService),
          cryptoUtilsRepositoryProvider.overrideWithValue(mockCryptoUtilsRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]);

        // wait for biometric auth
        await tester.pump(Duration(milliseconds: 300));

        verify(mockAuthRepository.isSessionExpired()).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verify(mockBiometricAuthRepository.isSupported()).called(1);
        verify(mockStorageService.hasMasterKey()).called(1);
        verify(mockBiometricAuthRepository.authenticate()).called(1);
        verify(mockCryptoService.init(any, any, any)).called(1);
        verify(mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate'))).called(1);
        expect(find.byType(ShadToast), findsOneWidget);
        expect(find.textContaining("Sign in successful"), findsOneWidget);
        expect(find.byType(VaultListPage), findsOneWidget);
      });

      testWidgets('Test biometric setup prompt with confirm ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(
          mockAuthRepository.signIn(email: anyNamed('email'), password: anyNamed('password')),
        ).thenAnswer((_) async {});
        when(mockAuthRepository.isSessionExpired()).thenAnswer((_) => Future.value(false));
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => Future.value(OpmUser.empty()));

        when(
          mockCryptoUtilsRepository.getCryptoUtils(any),
        ).thenAnswer((_) => Future.value(CryptoUtils.empty()));

        when(mockBiometricAuthRepository.isSupported()).thenAnswer((_) => Future.value(true));
        when(mockStorageService.hasMasterKey()).thenAnswer((_) => Future.value(false));

        when(mockCryptoService.init(any, any, any)).thenAnswer((_) => Future.value());

        when(
          mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate')),
        ).thenAnswer((_) => Future.value([]));

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          biometricAuthRepositoryProvider.overrideWithValue(mockBiometricAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          cryptoServiceProvider.overrideWithValue(mockCryptoService),
          cryptoUtilsRepositoryProvider.overrideWithValue(mockCryptoUtilsRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        verify(
          mockAuthRepository.signIn(email: 'test@example.com', password: 'password123'),
        ).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verify(mockBiometricAuthRepository.isSupported()).called(2);
        verify(mockStorageService.hasMasterKey()).called(1);

        expect(find.text("Biometrics Authentication"), findsOneWidget);
        expect(find.text("Enable"), findsOneWidget);
        expect(find.text("Skip for now"), findsOneWidget);

        // needed to fix a pending timer error
        await tester.tap(
          find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Enable"),
        );
        await tester.pumpAndSettle();

        verify(mockCryptoService.init(any, any, true)).called(1);
        expect(find.byType(VaultListPage), findsOneWidget);
      });

      testWidgets('Test biometric setup prompt with cancel ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(
          mockAuthRepository.signIn(email: anyNamed('email'), password: anyNamed('password')),
        ).thenAnswer((_) async {});
        when(mockAuthRepository.isSessionExpired()).thenAnswer((_) => Future.value(false));
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) => Future.value(OpmUser.empty()));

        when(
          mockCryptoUtilsRepository.getCryptoUtils(any),
        ).thenAnswer((_) => Future.value(CryptoUtils.empty()));

        when(mockBiometricAuthRepository.isSupported()).thenAnswer((_) => Future.value(true));
        when(mockStorageService.hasMasterKey()).thenAnswer((_) => Future.value(false));

        when(mockCryptoService.init(any, any, any)).thenAnswer((_) => Future.value());

        when(
          mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate')),
        ).thenAnswer((_) => Future.value([]));

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          biometricAuthRepositoryProvider.overrideWithValue(mockBiometricAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          cryptoServiceProvider.overrideWithValue(mockCryptoService),
          cryptoUtilsRepositoryProvider.overrideWithValue(mockCryptoUtilsRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        verify(
          mockAuthRepository.signIn(email: 'test@example.com', password: 'password123'),
        ).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verify(mockBiometricAuthRepository.isSupported()).called(2);
        verify(mockStorageService.hasMasterKey()).called(1);

        expect(find.text("Biometrics Authentication"), findsOneWidget);
        expect(find.text("Enable"), findsOneWidget);
        expect(find.text("Skip for now"), findsOneWidget);

        // needed to fix a pending timer error
        await tester.tap(
          find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Skip for now"),
        );
        await tester.pumpAndSettle();

        verify(mockCryptoService.init(any, any, false)).called(1);
        expect(find.byType(VaultListPage), findsOneWidget);
      });

      testWidgets('Test repository throws error ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(
          mockAuthRepository.signIn(email: anyNamed('email'), password: anyNamed('password')),
        ).thenThrow(Exception('Sign in failed'));
        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.textContaining('Failed to sign in'), findsOneWidget);
      });
    });
  }
}
