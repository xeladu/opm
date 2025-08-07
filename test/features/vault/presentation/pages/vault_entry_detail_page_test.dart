import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_entry_detail_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/edit_entry_button.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';

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
    });
  }
}
