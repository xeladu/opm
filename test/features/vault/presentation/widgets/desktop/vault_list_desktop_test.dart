import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../helper/app_setup.dart';
import '../../../../../helper/test_data_generator.dart';
import '../../../../../helper/test_error_suppression.dart';
import '../../../../../mocking/mocks.mocks.dart';

void main() {
  group("VaultListMobile", () {
    late MockVaultRepository mockVaultRepository;

    setUp(() {
      mockVaultRepository = MockVaultRepository();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);
    });

    testWidgets("Test empty list", (tester) async {
      final sut = Material(
        child: Scaffold(body: VaultListDesktop(passwords: [], vaultEmpty: true)),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.text("0 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNothing);
      expect(find.byType(EmptyList), findsOneWidget);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);
    });

    testWidgets("Test add entry", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsOneWidget);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsOneWidget);
    });

    testWidgets("Test edit entry and save", (tester) async {
      when(mockVaultRepository.editEntry(any)).thenAnswer((_) => Future.value());

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 500));
      await tester.tap(find.byIcon(LucideIcons.pen));
      await tester.pumpAndSettle();

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsOneWidget);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Save"));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);
    });

    testWidgets("Test edit entry and cancel", (tester) async {
      suppressOverflowErrors();

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 100));
      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pumpAndSettle();

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsOneWidget);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsOneWidget);

      await tester.enterText(find.byType(ShadInputFormField).first, "abc");
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Cancel"),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadDialog), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Leave"));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);
    });

    testWidgets("Test view entry", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 500));

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsOneWidget);
      expect(find.byType(VaultEntryActions), findsOneWidget);
    });

    testWidgets("Test duplicate entry", (tester) async {
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 500));

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsOneWidget);
      expect(find.byType(VaultEntryActions), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is GlyphButton && w.style == IconButtonStyle.standard && w.icon == LucideIcons.copy,
        ),
      );
      await tester.pumpAndSettle();

      verify(mockVaultRepository.addEntry(any)).called(1);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);
    });

    testWidgets("Test delete entry", (tester) async {
      when(mockVaultRepository.deleteEntry(any)).thenAnswer((_) => Future.value());

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            passwords: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 500));

      expect(find.text("2 entries found"), findsOneWidget);
      expect(find.byType(VaultSearchField), findsOneWidget);
      expect(find.byType(VaultListEntry), findsNWidgets(2));
      expect(find.byType(EmptyList), findsNothing);
      expect(find.byType(VaultListActions), findsOneWidget);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsOneWidget);
      expect(find.byType(VaultEntryActions), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.trash));
      await tester.pumpAndSettle();

      expect(find.byType(ShadDialog), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Delete"));
      await tester.pumpAndSettle();

      verify(mockVaultRepository.deleteEntry(any)).called(1);

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);
    });
  });
}
