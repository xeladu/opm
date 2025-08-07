import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/create_account_page.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import '../../../helper/app_setup.dart';
import '../../../helper/display_size.dart';
import '../../../helper/test_error_suppression.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  for (var sizeEntry in DisplaySizes.sizes.entries) {
    group('CreateAccountPage', () {
      late MockAuthRepository mockAuthRepository;
      late MockSaltRepository mockSaltRepository;
      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockAuthRepository = MockAuthRepository();
        mockSaltRepository = MockSaltRepository();
      });

      testWidgets('Test default elements ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        expect(
          find.byType(CreateAccoutPageMobile),
          DisplaySizeHelper.isMobile(sizeEntry.value)
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.byType(CreateAccoutPageDesktop),
          DisplaySizeHelper.isMobile(sizeEntry.value)
              ? findsNothing
              : findsOneWidget,
        );
      });

      testWidgets('Test non matching passwords ($deviceSizeName)', (
        tester,
      ) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(
          find.byType(PasswordFormField).first,
          'password123',
        );
        await tester.enterText(
          find.byType(PasswordFormField).last,
          'password456',
        );
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Passwords do not match'), findsNWidgets(2));
      });

      testWidgets('Test navigation to sign in page ($deviceSizeName)', (
        tester,
      ) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.dragUntilVisible(
          find.byType(SecondaryButton),
          find.byType(SingleChildScrollView),
          Offset(0, -1000),
        );
        await tester.tap(find.byType(SecondaryButton, skipOffstage: false));
        await tester.pumpAndSettle();

        expect(find.byType(SignInPage), findsOneWidget);
      });

      testWidgets('Test missing password confirmation ($deviceSizeName)', (
        tester,
      ) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(
          find.byType(PasswordFormField).first,
          'password123',
        );
        await tester.enterText(find.byType(PasswordFormField).last, '');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Please enter a value'), findsOneWidget);
      });

      testWidgets('Test missing email error ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), '');
        await tester.enterText(
          find.byType(PasswordFormField).first,
          'password123',
        );
        await tester.enterText(
          find.byType(PasswordFormField).last,
          'password123',
        );
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Please enter a value'), findsOneWidget);
      });

      testWidgets('Test missing passwords error ($deviceSizeName)', (
        tester,
      ) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(find.byType(PasswordFormField).first, '');
        await tester.enterText(find.byType(PasswordFormField).last, '');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        expect(find.text('Please enter a value'), findsNWidgets(2));
      });

      testWidgets('Test valid registration ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(
          mockAuthRepository.createAccount(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async {});

        when(
          mockSaltRepository.saveUserSalt(any, any),
        ).thenAnswer((_) => Future.value(null));

        final sut = CreateAccountPage();
        await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]);

        await tester.enterText(find.byType(EmailFormField), 'test@example.com');
        await tester.enterText(
          find.byType(PasswordFormField).first,
          'password123',
        );
        await tester.enterText(
          find.byType(PasswordFormField).last,
          'password123',
        );
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();

        verify(
          mockAuthRepository.createAccount(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });
    });
  }
}
