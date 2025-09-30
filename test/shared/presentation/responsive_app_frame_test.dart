import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/application/providers/active_filter_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/show_search_field_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/shared/presentation/sheets/entry_filter_sheet.dart';
import 'package:open_password_manager/shared/presentation/user_menu.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';
import '../../helper/display_size.dart';
import '../../helper/test_data_generator.dart';
import '../../mocking/mocks.mocks.dart';

void main() {
  group("ResponsiveAppFrame", () {
    late MockVaultRepository mockVaultRepository;
    late MockStorageService mockStorageService;
    late MockCryptographyRepository mockCryptographyRepository;

    setUp(() {
      mockVaultRepository = MockVaultRepository();
      mockStorageService = MockStorageService();
      mockCryptographyRepository = MockCryptographyRepository();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = ResponsiveAppFrame(content: Card());
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ResponsiveAppFrame), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets("Test mobile elements", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.first.value);

      final sut = ResponsiveAppFrame(
        mobileContent: Text("mobile"),
        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
        desktopContent: Text("desktop"),
        desktopButton: FloatingActionButton(child: Text("desktop"), onPressed: () {}),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ResponsiveAppFrame), findsOneWidget);
      expect(find.text("mobile"), findsNWidgets(2));
      expect(find.byType(GlyphButton), findsNWidgets(2));
      expect(find.byType(UserMenu), findsOneWidget);
    });

    testWidgets("Test desktop elements", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.last.value);

      final sut = ResponsiveAppFrame(
        mobileContent: Text("mobile"),
        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
        desktopContent: Text("desktop"),
        desktopButton: FloatingActionButton(child: Text("desktop"), onPressed: () {}),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ResponsiveAppFrame), findsOneWidget);
      expect(find.text("desktop"), findsNWidgets(2));
      expect(find.byType(GlyphButton), findsNothing);
      expect(find.byType(UserMenu), findsOneWidget);
    });

    testWidgets("Test mobile search field", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.first.value);

      final sut = ResponsiveAppFrame(
        content: Text("mobile"),
        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
      );
      await AppSetup.pumpPage(tester, sut, []);

      final providerContainer = tester.container();

      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      expect(providerContainer.read(showSearchFieldProvider), isFalse);

      await tester.tap(find.byIcon(LucideIcons.search));
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      expect(providerContainer.read(showSearchFieldProvider), isTrue);

      expect(find.byIcon(LucideIcons.settings2), findsOneWidget);
    });

    testWidgets("Test folder selection", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.first.value);

      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value(
          [
            TestDataGenerator.vaultEntry(folder: "folder1"),
            TestDataGenerator.vaultEntry(folder: "folder2"),
            TestDataGenerator.vaultEntry(folder: "folder3"),
          ].toList(),
        ),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = ResponsiveAppFrame(
        content: Text("mobile"),
        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
      ]);

      final providerContainer = tester.container();

      expect(find.byIcon(LucideIcons.settings2), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.settings2));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsOneWidget);
      expect(find.text("All entries"), findsOneWidget);
      expect(find.text("folder1"), findsOneWidget);
      expect(find.text("folder2"), findsOneWidget);
      expect(find.text("folder3"), findsOneWidget);

      await tester.tap(find.text("folder2"));
      await tester.pump();

      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsNothing);
      expect(providerContainer.read(activeFilterProvider)!.displayValue, "Folder folder2");

      await tester.tap(find.byIcon(LucideIcons.settings2));
      await tester.pumpAndSettle();

      await tester.tap(find.text("All entries"));
      await tester.pump();

      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsNothing);
      expect(providerContainer.read(activeFilterProvider), isNull);
    });

    testWidgets("Test type selection", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.first.value);

      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value(
          [
            TestDataGenerator.vaultEntry(type: VaultEntryType.credential.name),
            TestDataGenerator.vaultEntry(type: VaultEntryType.note.name),
            TestDataGenerator.vaultEntry(type: VaultEntryType.ssh.name),
          ].toList(),
        ),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = ResponsiveAppFrame(
        content: Text("mobile"),

        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
      ]);

      final providerContainer = tester.container();

      expect(find.byIcon(LucideIcons.settings2), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.settings2));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsOneWidget);

      await tester.tap(find.text(VaultEntryType.credential.toNiceString()));
      await tester.pump();

      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsNothing);
      expect(
        providerContainer.read(activeFilterProvider)!.displayValue,
        VaultEntryType.credential.toNiceString(),
      );

      await tester.tap(find.byIcon(LucideIcons.settings2));
      await tester.pumpAndSettle();

      await tester.tap(find.text("All entries"));
      await tester.pump();

      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsNothing);
      expect(providerContainer.read(activeFilterProvider), isNull);
    });

    testWidgets("Test hide mobile search field", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.first.value);

      final sut = ResponsiveAppFrame(
        content: Text("mobile"),
        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
        hideSearchButton: true,
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byIcon(LucideIcons.search), findsNothing);
    });

    testWidgets("Test hide folder button", (tester) async {
      await DisplaySizeHelper.setSize(tester, DisplaySizes.sizes.entries.first.value);

      final sut = ResponsiveAppFrame(
        content: Text("mobile"),
        mobileButton: FloatingActionButton(child: Text("mobile"), onPressed: () {}),
        hideFolderButton: true,
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byIcon(LucideIcons.folder), findsNothing);
    });
  });
}
