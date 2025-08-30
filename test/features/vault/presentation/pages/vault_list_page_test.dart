import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_entry_button.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/mobile/vault_list_mobile.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
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
      final deviceSizeName = sizeEntry.key;

      setUp(() {
        mockVaultRepository = MockVaultRepository();
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

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
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

        final sut = VaultListPage();
        await AppSetup.pumpPage(tester, sut, [
          vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
          noConnectionProvider.overrideWith(() => FakeNoConnectionState(true))
        ]);

        await tester.tap(find.byType(AddEntryButton));
        await tester.pumpAndSettle();

        expect(find.byType(ShadDialog), findsOneWidget);
        expect(find.text("No Internet Connection"), findsOneWidget);
      });
    });
  }
}
