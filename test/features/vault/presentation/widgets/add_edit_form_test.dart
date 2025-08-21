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
    late MockVaultRepository mockVaultRepository;
    setUp(() {
      mockVaultRepository = MockVaultRepository();
    });

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
      expect(find.text("my-folder"), findsOneWidget);
    });

    testWidgets("Test change folder", (tester) async {
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.vaultEntry(folder: "folder1"),
          TestDataGenerator.vaultEntry(folder: "folder2"),
        ]),
      );
      final sut = Material(
        child: Scaffold(
          body: AddEditForm(entry: TestDataGenerator.vaultEntry(), onCancel: () {}, onSave: () {}),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-user"), findsOneWidget);
      expect(find.text("my-pass"), findsOneWidget);
      expect(find.textContaining("url1"), findsOneWidget);
      expect(find.textContaining("url2"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // TODO This test does not trigger the selection dropdown

      expect(find.byType(ShadSelectFormField<String>), findsOneWidget);
      await tester.tap(find.byType(ShadSelectFormField<String>));
      await tester.pumpAndSettle();

      expect(find.byType(ShadOption<String>), findsNWidgets(3));
      await tester.tap(find.byType(ShadOption<String>).last);
      await tester.pumpAndSettle();

      expect(find.text("folder2"), findsOneWidget);
      expect(find.text("my-folder"), findsNothing);
    }, skip: true);

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
