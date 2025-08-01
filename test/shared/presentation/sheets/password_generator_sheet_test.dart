import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/password_generator_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/sheets/password_generator_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/mocks.mocks.dart';

void main() {
  group("PasswordGeneratorSheet", () {
    late MockPasswordGeneratorRepository mockPasswordGeneratorRepository;

    setUp(() {
      mockPasswordGeneratorRepository = MockPasswordGeneratorRepository();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) =>
                    PasswordGeneratorSheet(onGeneratePassword: (p0) {}),
                context: context,
              ),
            ),
          ),
        ),
      );

      when(
        mockPasswordGeneratorRepository.generatePassword(
          any,
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) => "generated password");

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          passwordGeneratorRepositoryProvider.overrideWithValue(
            mockPasswordGeneratorRepository,
          ),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordGeneratorSheet), findsOneWidget);
      expect(find.byType(ShadSlider), findsOneWidget);
      expect(find.byType(ShadSwitch), findsNWidgets(4));
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.text("Copy password"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);

      expect(find.text("generated password"), findsOneWidget);
    });

    testWidgets("Test password return", (tester) async {
      String? result;

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => PasswordGeneratorSheet(
                  onGeneratePassword: (option) {
                    result = option;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      when(
        mockPasswordGeneratorRepository.generatePassword(
          any,
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) => "generated password");

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          passwordGeneratorRepositoryProvider.overrideWithValue(
            mockPasswordGeneratorRepository,
          ),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PasswordGeneratorSheet)),
      );
      container
          .read(selectedEntryProvider.notifier)
          .setEntry(VaultEntry.empty());

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordGeneratorSheet), findsNothing);
      expect(result, "generated password");
    });

    testWidgets("Test no password return when no entry selected", (
      tester,
    ) async {
      String? result;

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => PasswordGeneratorSheet(
                  onGeneratePassword: (option) {
                    result = option;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      when(
        mockPasswordGeneratorRepository.generatePassword(
          any,
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) => "generated password");

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          passwordGeneratorRepositoryProvider.overrideWithValue(
            mockPasswordGeneratorRepository,
          ),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordGeneratorSheet), findsOneWidget);
      expect(find.byType(ShadToast), findsOneWidget);
      expect(result, isNull);
    });

    testWidgets("Test options error", (tester) async {
      String? result;

      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () => showShadSheet(
                builder: (context) => PasswordGeneratorSheet(
                  onGeneratePassword: (option) {
                    result = option;
                  },
                ),
                context: context,
              ),
            ),
          ),
        ),
      );

      when(
        mockPasswordGeneratorRepository.generatePassword(
          any,
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) => "generated password");

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          passwordGeneratorRepositoryProvider.overrideWithValue(
            mockPasswordGeneratorRepository,
          ),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Use uppercase letters (A-Z)"));
      await tester.tap(find.text("Use lowercase letters (a-z)"));
      await tester.pumpAndSettle();

      expect(find.text("Choose at least two options!"), findsNothing);

      await tester.tap(find.text("Use numbers (0-9)"));
      await tester.tap(find.text("Use special characters (!@#\$%^&*)"));
      await tester.pumpAndSettle();

      expect(find.text("Choose at least two options!"), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordGeneratorSheet), findsOneWidget);
      expect(find.byType(ShadToast), findsOneWidget);
      expect(result, isNull);
    });
  });
}
