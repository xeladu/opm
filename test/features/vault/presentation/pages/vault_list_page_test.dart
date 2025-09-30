import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/application/providers/active_filter_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_entry_button.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/mobile/vault_list_mobile.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/domain/entities/filter.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../mocking/fakes.dart';
import '../../../../mocking/mocks.mocks.dart';

void main() {
  for (var sizeEntry in DisplaySizes.sizes.entries) {
    group('VaultListPage', () {
      late MockVaultRepository mockVaultRepository;
      late MockStorageService mockStorageService;
      late MockCryptographyRepository mockCryptographyRepository;
      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockVaultRepository = MockVaultRepository();
        mockStorageService = MockStorageService();
        mockCryptographyRepository = MockCryptographyRepository();
      });

      testWidgets('Test default elements ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate'))).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]);

        expect(find.byType(ResponsiveAppFrame), findsOneWidget);
        expect(
          find.byType(VaultListDesktop),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsNothing : findsOneWidget,
        );
        expect(
          find.byType(VaultListMobile),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(AddEntryButton),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsOneWidget : findsNothing,
        );
      });

      testWidgets('Test default elements offline ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate'))).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        when(mockCryptographyRepository.decrypt(any)).thenAnswer((_) => Future.value("decrypted"));
        when(mockStorageService.loadOfflineVaultData()).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          noConnectionProvider.overrideWith(() => FakeNoConnectionState(true)),
        ]);

        expect(find.byType(ResponsiveAppFrame), findsOneWidget);
        expect(
          find.byType(VaultListDesktop),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsNothing : findsOneWidget,
        );
        expect(
          find.byType(VaultListMobile),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(AddEntryButton),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsOneWidget : findsNothing,
        );
      });

      testWidgets('Test offline dialog ($deviceSizeName)', (tester) async {
        // Test only on mobile
        if (!DisplaySizeHelper.isMobile(sizeEntry.value)) return;

        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate'))).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        when(mockCryptographyRepository.decrypt(any)).thenAnswer((_) => Future.value("decrypted"));
        when(mockStorageService.loadOfflineVaultData()).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          noConnectionProvider.overrideWith(() => FakeNoConnectionState(true)),
        ]);

        await tester.tap(find.byType(AddEntryButton));
        await tester.pumpAndSettle();

        expect(find.byType(ShadDialog), findsOneWidget);
        expect(find.text("No Internet Connection"), findsOneWidget);
      });

      testWidgets('Test type filtering ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate'))).thenAnswer(
          (_) => Future.value([
            VaultEntry.empty().copyWith(
              type: VaultEntryType.credential.name,
              name: "A",
              folder: "D",
            ),
            VaultEntry.empty().copyWith(type: VaultEntryType.note.name, name: "B", folder: "E"),
            VaultEntry.empty().copyWith(type: VaultEntryType.api.name, name: "C", folder: "F"),
          ]),
        );

        when(mockCryptographyRepository.decrypt(any)).thenAnswer((_) => Future.value("decrypted"));
        when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          activeFilterProvider.overrideWith(
            () => FakeActiveFilterState(
              Filter(
                name: VaultEntryType.note.name,
                displayValue: VaultEntryType.note.toNiceString(),
              ),
            ),
          ),
        ]);

        expect(
          find.byWidgetPredicate(
            (w) => w is VaultListEntry && w.entry.folder == "E" && w.entry.name == "B",
          ),
          findsOneWidget,
        );
        expect(
          find.byIcon(VaultEntryType.note.toIcon()),
          findsNWidgets(2),
          reason: "Expect one in the title line and one in the vault list",
        );
      });

      testWidgets('Test folder filtering ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed('onUpdate'))).thenAnswer(
          (_) => Future.value([
            VaultEntry.empty().copyWith(
              type: VaultEntryType.credential.name,
              name: "A",
              folder: "D",
            ),
            VaultEntry.empty().copyWith(
              type: VaultEntryType.credential.name,
              name: "B",
              folder: "E",
            ),
            VaultEntry.empty().copyWith(
              type: VaultEntryType.credential.name,
              name: "C",
              folder: "F",
            ),
          ]),
        );

        when(mockCryptographyRepository.decrypt(any)).thenAnswer((_) => Future.value("decrypted"));
        when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
          activeFilterProvider.overrideWith(
            () => FakeActiveFilterState(Filter(name: "D", displayValue: "D")),
          ),
        ]);

        expect(
          find.byWidgetPredicate(
            (w) => w is VaultListEntry && w.entry.folder == "D" && w.entry.name == "A",
          ),
          findsOneWidget,
        );
        expect(find.byIcon(LucideIcons.folder), findsOneWidget);
      });
    });
  }
}
