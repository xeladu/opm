import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/import_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/file_picker_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/offline_mode_available_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/sheets/export_sheet.dart';
import 'package:open_password_manager/shared/presentation/sheets/import_sheet.dart';
import 'package:open_password_manager/shared/presentation/sheets/settings_sheet.dart';
import 'package:open_password_manager/shared/presentation/user_menu.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helper/app_setup.dart';
import '../../helper/test_data_generator.dart';
import '../../helper/test_error_suppression.dart';
import '../../mocking/fakes.dart';
import '../../mocking/mocks.mocks.dart';

void main() {
  group("UserMenu", () {
    late MockAuthRepository mockAuthRepository;
    late MockExportRepository mockExportRepository;
    late MockVaultRepository mockVaultRepository;
    late MockImportRepository mockImportRepository;
    late MockFilePickerService mockFilePickerService;
    late MockStorageService mockStorageService;
    late MockCryptographyRepository mockCryptographyRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockExportRepository = MockExportRepository();
      mockVaultRepository = MockVaultRepository();
      mockImportRepository = MockImportRepository();
      mockFilePickerService = MockFilePickerService();
      mockStorageService = MockStorageService();
      mockCryptographyRepository = MockCryptographyRepository();
    });

    testWidgets("Test default elements", (tester) async {
      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      expect(find.byType(UserMenu), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets("Test logout", (tester) async {
      final sut = Material(child: Scaffold(body: UserMenu()));

      suppressOverflowErrors();

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          offlineModeAvailableProvider.overrideWith(() => FakeOfflineModeAvailableState(false)),
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

    testWidgets("Test JSON export", (tester) async {
      when(mockExportRepository.exportPasswordEntriesJson(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          exportRepositoryProvider.overrideWithValue(mockExportRepository),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Export vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsNothing);

      verify(mockExportRepository.exportPasswordEntriesJson(any)).called(1);
    });

    testWidgets("Test CSV export", (tester) async {
      when(mockExportRepository.exportPasswordEntriesCsv(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          exportRepositoryProvider.overrideWithValue(mockExportRepository),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Export vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsOneWidget);

      await tester.tap(find.text("JSON"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("CSV"));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExportSheet), findsNothing);

      verify(mockExportRepository.exportPasswordEntriesCsv(any)).called(1);
    });

    testWidgets("Test import OPM", (tester) async {
      suppressOverflowErrors();
      when(mockImportRepository.validateOpmFile(any)).thenAnswer((_) {});
      when(mockImportRepository.importFromOpm(any)).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );
      when(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          importRepositoryProvider.overrideWithValue(mockImportRepository),
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Import vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsNothing);

      verify(mockImportRepository.importFromOpm(any)).called(1);
      verify(mockImportRepository.validateOpmFile(any)).called(1);
      verify(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).called(1);
      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(1);
    });

    testWidgets("Test import 1Password", (tester) async {
      suppressOverflowErrors();
      when(mockImportRepository.validate1PasswordFile(any)).thenAnswer((_) {});
      when(mockImportRepository.importFrom1Password(any)).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );
      when(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          importRepositoryProvider.overrideWithValue(mockImportRepository),
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Import vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Open Password Manager"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("1Password"));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsNothing);

      verify(mockImportRepository.importFrom1Password(any)).called(1);
      verify(mockImportRepository.validate1PasswordFile(any)).called(1);
      verify(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).called(1);
      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(1);
    });

    testWidgets("Test import LastPass", (tester) async {
      suppressOverflowErrors();
      when(mockImportRepository.validateLastPassFile(any)).thenAnswer((_) {});
      when(mockImportRepository.importFromLastPass(any)).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );
      when(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          importRepositoryProvider.overrideWithValue(mockImportRepository),
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Import vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Open Password Manager"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("LastPass"));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsNothing);

      verify(mockImportRepository.importFromLastPass(any)).called(1);
      verify(mockImportRepository.validateLastPassFile(any)).called(1);
      verify(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).called(1);
      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(1);
    });

    testWidgets("Test import Bitwarden", (tester) async {
      suppressOverflowErrors();
      when(mockImportRepository.validateBitwardenFile(any)).thenAnswer((_) {});
      when(mockImportRepository.importFromBitwarden(any)).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );
      when(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          importRepositoryProvider.overrideWithValue(mockImportRepository),
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Import vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Open Password Manager"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Bitwarden"));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsNothing);

      verify(mockImportRepository.importFromBitwarden(any)).called(1);
      verify(mockImportRepository.validateBitwardenFile(any)).called(1);
      verify(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).called(1);
      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(1);
    });

    testWidgets("Test import KeePass", (tester) async {
      suppressOverflowErrors();
      when(mockImportRepository.validateKeepassFile(any)).thenAnswer((_) {});
      when(mockImportRepository.importFromKeepass(any)).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );
      when(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          importRepositoryProvider.overrideWithValue(mockImportRepository),
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Import vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Open Password Manager"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("KeePass", skipOffstage: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsNothing);

      verify(mockImportRepository.importFromKeepass(any)).called(1);
      verify(mockImportRepository.validateKeepassFile(any)).called(1);
      verify(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).called(1);
      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(1);
    });

    testWidgets("Test import Keeper", (tester) async {
      suppressOverflowErrors();
      when(mockImportRepository.validateKeeperFile(any)).thenAnswer((_) {});
      when(mockImportRepository.importFromKeeper(any)).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );
      when(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).thenAnswer(
        (_) => Future.value(
          FilePickerResult([
            PlatformFile(
              path: "folder/subfolder",
              name: "my-file",
              size: 64,
              bytes: Uint8List.fromList([116, 101, 115, 116]),
            ),
          ]),
        ),
      );
      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.randomVaultEntry(),
          TestDataGenerator.randomVaultEntry(),
        ]),
      );

      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          importRepositoryProvider.overrideWithValue(mockImportRepository),
          filePickerServiceProvider.overrideWithValue(mockFilePickerService),
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]),
      );

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Import vault"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Pick CSV file"),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Open Password Manager"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Keeper"));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((w) => w is PrimaryButton && w.caption == "Import"));
      await tester.pumpAndSettle();

      expect(find.byType(ImportSheet), findsNothing);

      verify(mockImportRepository.importFromKeeper(any)).called(1);
      verify(mockImportRepository.validateKeeperFile(any)).called(1);
      verify(
        mockFilePickerService.pickFile(allowedExtensions: anyNamed("allowedExtensions")),
      ).called(1);
      verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
      verify(mockStorageService.storeOfflineVaultData(any)).called(1);
    });

    testWidgets("Test settings", (tester) async {
      final sut = Scaffold(body: UserMenu());

      await tester.runAsync(() async => await AppSetup.pumpPage(tester, sut, []));

      await tester.tap(find.byType(UserMenu));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Settings"));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSheet), findsOneWidget);
    });
  });
}
