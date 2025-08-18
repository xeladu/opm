import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/desktop/vault_list_desktop.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/mobile/vault_list_mobile.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';
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
      });
    });
  }
}
