import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/salt_repository_provider.dart';
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
      late MockCryptographyRepository mockCryptographyRepository;
      late MockSaltRepository mockSaltRepository;
      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockAuthRepository = MockAuthRepository();
        mockCryptographyRepository = MockCryptographyRepository();
        mockSaltRepository = MockSaltRepository();
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
          DisplaySizeHelper.isMobile(sizeEntry.value)
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.byType(SignInPageDesktop),
          DisplaySizeHelper.isMobile(sizeEntry.value)
              ? findsNothing
              : findsOneWidget,
        );
      });

      testWidgets('Test navigation to create account page ($deviceSizeName)', (
        tester,
      ) async {
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
          mockAuthRepository.signIn(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async {});
        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) => Future.value(OpmUser.empty()));

        when(
          mockSaltRepository.getUserSalt(any),
        ).thenAnswer((_) => Future.value(""));

        final sut = SignInPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          cryptographyRepositoryProvider.overrideWithValue(
            mockCryptographyRepository,
          ),
          saltRepositoryProvider.overrideWithValue(mockSaltRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField), 'password123');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        verify(
          mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
        expect(find.byType(ShadToast), findsOneWidget);
        expect(find.textContaining("Sign in successful"), findsOneWidget);
      });

      testWidgets('Test repository throws error ($deviceSizeName)', (
        tester,
      ) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(
          mockAuthRepository.signIn(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
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
