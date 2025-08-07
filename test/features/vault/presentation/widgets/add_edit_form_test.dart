import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../mocking/mocks.mocks.dart';

void main() {
  group("AddEditForm", () {
    testWidgets("Test add form", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: AddEditForm(onCancel: () {}, onSave: () {}),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));
    });

    testWidgets("Test edit form", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: AddEditForm(entry: TestDataGenerator.vaultEntry(), onCancel: () {}, onSave: () {}),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-user"), findsOneWidget);
      expect(find.text("my-pass"), findsOneWidget);
      expect(find.textContaining("url1"), findsOneWidget);
      expect(find.textContaining("url2"), findsOneWidget);
    });

    testWidgets("Test invalid save", (tester) async {
      bool saved = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            onCancel: () {},
            onSave: () {
              saved = true;
            },
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
      expect(find.text("Required"), findsOneWidget);
    });

    testWidgets("Test save", (tester) async {
      bool saved = false;

      final mockVaultRepository = MockVaultRepository();

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            onCancel: () {},
            onSave: () {
              saved = true;
            },
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.enterText(find.byType(ShadInputFormField).first, "Test");
      await tester.pumpAndSettle();

      expect(find.byType(ShadBadge), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(saved, isTrue);
    });

    testWidgets("Test cancel", (tester) async {
      bool cancel = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            onCancel: () {
              cancel = true;
            },
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(cancel, isTrue);
    });

    testWidgets("Test cancel with confirmation", (tester) async {
      bool cancel = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            onCancel: () {
              cancel = true;
            },
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.enterText(find.byType(ShadInputFormField).first, "Test");
      await tester.pumpAndSettle();

      expect(find.byType(ShadBadge), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Leave"));
      await tester.pumpAndSettle();

      expect(cancel, isTrue);
    });

    testWidgets("Test cancel with rejected confirmation", (tester) async {
      bool cancel = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            onCancel: () {
              cancel = true;
            },
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.enterText(find.byType(ShadInputFormField).first, "Test");
      await tester.pumpAndSettle();

      expect(find.byType(ShadBadge), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Stay"));
      await tester.pumpAndSettle();

      expect(cancel, isFalse);
    });
  });
}
