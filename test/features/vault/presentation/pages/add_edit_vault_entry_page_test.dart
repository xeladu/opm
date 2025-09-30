import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../helper/test_error_suppression.dart';
import '../../../../mocking/mocks.mocks.dart';

void main() {
  for (var sizeEntry in DisplaySizes.sizes.entries) {
    group('AddEditVaultEntryPage', () {
      late MockVaultRepository mockVaultRepository;
      late MockStorageService mockStorageService;
      late MockCryptographyRepository mockCryptographyRepository;

      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockVaultRepository = MockVaultRepository();
        mockStorageService = MockStorageService();
        mockCryptographyRepository = MockCryptographyRepository();
      });

      testWidgets('Test default elements (edit) ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        final sut = AddEditVaultEntryPage(
          template: VaultEntryType.credential,
          onSave: () {},
          entry: TestDataGenerator.randomVaultEntry(),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(ResponsiveAppFrame), findsOneWidget);
        expect(find.byType(AddEditForm), findsOneWidget);
        expect(find.byIcon(LucideIcons.search), findsNothing);
        expect(find.text("Edit Vault Entry"), findsOneWidget);
      });

      testWidgets('Test default elements (add) ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        final sut = AddEditVaultEntryPage(template: VaultEntryType.credential, onSave: () {});
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(ResponsiveAppFrame), findsOneWidget);
        expect(find.byType(AddEditForm), findsOneWidget);
        expect(find.byIcon(LucideIcons.search), findsNothing);
        expect(find.text("Add Vault Entry"), findsOneWidget);
      });

      testWidgets('Test save ($deviceSizeName)', (tester) async {
        bool saved = false;
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        when(mockVaultRepository.editEntry(any)).thenAnswer((_) => Future.value());
        when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
          (_) => Future.value([
            TestDataGenerator.randomVaultEntry(),
            TestDataGenerator.randomVaultEntry(),
          ]),
        );

        when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

        final sut = AddEditVaultEntryPage(
          template: VaultEntryType.credential,
          entry: TestDataGenerator.randomVaultEntry(),
          onSave: () {
            saved = true;
          },
        );
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          storageServiceProvider.overrideWithValue(mockStorageService),
          cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
        ]);

        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        expect(saved, isTrue);

        verify(mockCryptographyRepository.encrypt(any)).callCount > 0;
        verify(mockStorageService.storeOfflineVaultData(any)).called(2);
      });

      testWidgets('Test cancel with dialog ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);
        suppressOverflowErrors();

        when(mockVaultRepository.editEntry(any)).thenAnswer((_) => Future.value());

        final sut = AddEditVaultEntryPage(
          template: VaultEntryType.credential,
          entry: TestDataGenerator.randomVaultEntry(),
          onSave: () {},
        );
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]);

        final container = tester.container();
        container.read(hasChangesProvider.notifier).setHasChanges(true);
        container.read(addEditModeActiveProvider.notifier).setMode(true);

        await tester.tap(find.byType(SecondaryButton));
        await tester.pumpAndSettle();

        expect(find.byType(ShadDialog), findsOneWidget);

        await tester.tap(
          find.byWidgetPredicate((w) => w is SecondaryButton && w.caption == "Stay"),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AddEditVaultEntryPage), findsOneWidget);
      });
    });
  }
}
