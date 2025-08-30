import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_entry_detail_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/edit_entry_button.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../mocking/fakes.dart';

void main() {
  for (var sizeEntry in DisplaySizes.sizes.entries) {
    group('VaultEntryDetailPage', () {
      final deviceSizeName = sizeEntry.key;

      testWidgets('Test default elements ($deviceSizeName)', (tester) async {
        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        final sut = VaultEntryDetailPage(entry: TestDataGenerator.randomVaultEntry());
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(ResponsiveAppFrame), findsOneWidget);
        expect(find.byType(VaultEntryDetails), findsOneWidget);
        expect(
          find.byType(EditEntryButton),
          DisplaySizeHelper.isMobile(sizeEntry.value) ? findsOneWidget : findsNothing,
        );
        expect(find.byIcon(LucideIcons.search), findsNothing);
      });

      testWidgets('Test offline dialog ($deviceSizeName)', (tester) async {
        // Test only on mobile
        if (!DisplaySizeHelper.isMobile(sizeEntry.value)) return;

        await DisplaySizeHelper.setSize(tester, sizeEntry.value);

        final sut = VaultEntryDetailPage(entry: TestDataGenerator.randomVaultEntry());
        await AppSetup.pumpPage(tester, sut, [
          noConnectionProvider.overrideWith(() => FakeNoConnectionState(true)),
        ]);

        await tester.tap(find.byType(EditEntryButton));
        await tester.pumpAndSettle();

        expect(find.byType(ShadDialog), findsOneWidget);
        expect(find.text("No Internet Connection"), findsOneWidget);
      });
    });
  }
}
