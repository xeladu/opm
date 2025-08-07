import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/shared/presentation/sheets/export_sheet.dart';
import 'package:open_password_manager/shared/presentation/sheets/settings_sheet.dart';
import 'package:open_password_manager/shared/presentation/user_menu.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';
import '../../helper/test_error_suppression.dart';
import '../../mocking/mocks.mocks.dart';

void main() {
  group("UserMenu", () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      expect(find.byType(UserMenu), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets("Test logout", (tester) async {
      final sut = Material(child: Scaffold(body: UserMenu()));

      suppressOverflowErrors();

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ]),
      );

      when(mockAuthRepository.signOut()).thenAnswer((_) => Future.value());

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Log out"));
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.byType(ShadToast), findsOneWidget);
      verify(mockAuthRepository.signOut()).called(1);
    });

    testWidgets("Test export", (tester) async {
      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Export vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsOneWidget);
    });

    testWidgets("Test settings", (tester) async {
      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, []),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSheet), findsOneWidget);
    });
  });
}
