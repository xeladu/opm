import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../mocking/mocks.mocks.dart';

void main() {
  for (var sizeEntry in DisplaySizes.sizes.entries) {
    group('AddEditVaultEntryPage', () {
      late MockVaultRepository mockVaultRepository;
      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockVaultRepository = MockVaultRepository();
      });

      testWidgets('Test default elements (edit) ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        final sut = AddEditVaultEntryPage(
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

        final sut = AddEditVaultEntryPage(onSave: () {});
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

        final sut = AddEditVaultEntryPage(
          entry: TestDataGenerator.randomVaultEntry(),
          onSave: () {
            saved = true;
          },
        );
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        ]);

        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        expect(saved, isTrue);
      });
    });
  }
}
