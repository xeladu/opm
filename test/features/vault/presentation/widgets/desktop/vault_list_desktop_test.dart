import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/empty_list.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_actions.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_search_field.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../helper/app_setup.dart';
import '../../../../../helper/test_data_generator.dart';
import '../../../../../helper/test_error_suppression.dart';
import '../../../../../mocking/fakes.dart';
import '../../../../../mocking/mocks.mocks.dart';

void main() {
  group("VaultListDesktop", () {
    late MockVaultRepository mockVaultRepository;
    late MockStorageService mockStorageService;
    late MockCryptographyRepository mockCryptographyRepository;

    setUp(() {
      mockVaultRepository = MockVaultRepository();
      mockStorageService = MockStorageService();
      mockCryptographyRepository = MockCryptographyRepository();
    });

    Future<void> expectNoConnectionDialog(WidgetTester tester, Finder trigger) async {
      await tester.tap(trigger);
      await tester.pumpAndSettle();

      expect(find.byType(ShadDialog), findsOneWidget);
      expect(find.text("No Internet Connection"), findsOneWidget);

      await tester.tap(find.text("Close"));
      await tester.pumpAndSettle();

      expect(find.byType(ShadDialog), findsNothing);
    }

    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
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
        child: Scaffold(body: VaultListDesktop(entries: [], vaultEmpty: true)),
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
      when(
        mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate")),
      ).thenAnswer((_) => Future.value([TestDataGenerator.vaultEntry()]));

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
      ]);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Credentials"));
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
      when(
        mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate")),
      ).thenAnswer((_) => Future.value([TestDataGenerator.vaultEntry()]));
      when(mockVaultRepository.editEntry(any)).thenAnswer((_) => Future.value());
      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
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

      await tester.ensureVisible(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Save"),
      );
      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Save"));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditForm), findsNothing);
      expect(find.byType(VaultEntryDetails), findsNothing);
      expect(find.byType(VaultEntryActions), findsNothing);

      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(3);
    });

    testWidgets("Test edit entry and cancel", (tester) async {
      suppressOverflowErrors();

      when(
        mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate")),
      ).thenAnswer((_) => Future.value([TestDataGenerator.vaultEntry()]));

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        storageServiceProvider.overrideWithValue(mockStorageService),
      ]);

      final container = tester.container();
      container.read(allEntriesProvider);
      await tester.pumpAndSettle();

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

      await tester.ensureVisible(
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Cancel"),
      );
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

      verifyNever(mockStorageService.storeOfflineVaultData(any));
    });

    testWidgets("Test view entry", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
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
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
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

      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(2);
    });

    testWidgets("Test delete entry", (tester) async {
      when(mockVaultRepository.deleteEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
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

      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(2);
    });

    testWidgets("Test offline dialogs", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListDesktop(
            entries: [TestDataGenerator.randomVaultEntry(), TestDataGenerator.randomVaultEntry()],
            vaultEmpty: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        noConnectionProvider.overrideWith(() => FakeNoConnectionState(true)),
      ]);

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 500));

      // delete button
      await expectNoConnectionDialog(tester, find.byIcon(LucideIcons.trash));

      // edit button
      await expectNoConnectionDialog(tester, find.byIcon(LucideIcons.pen));

      // duplicate button
      await expectNoConnectionDialog(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w is GlyphButton && w.style == IconButtonStyle.standard && w.icon == LucideIcons.copy,
        ),
      );

      await tester.tap(find.byType(VaultListEntry).first);
      await tester.pump(Duration(milliseconds: 500));

      // add button
      await expectNoConnectionDialog(
        tester,
        find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Add new entry"),
      );
    });
  });
}
