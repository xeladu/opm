import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/add_edit_vault_entry_page.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_entry_detail_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/favicon.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry_popup.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/display_size.dart';
import '../../../../helper/test_data_generator.dart';

void main() {
  group("VaultListEntry", () {
    for (var sizeEntry in DisplaySizes.sizes.entries) {
      final deviceSize = sizeEntry.key;
      final isMobile =
          sizeEntry.value == DisplaySizes.sizes.entries.first.value;
      final vaultEntry = TestDataGenerator.vaultEntry();

      testWidgets("Test default elements ($deviceSize)", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntry(
              selected: false,
              isMobile: isMobile,
              entry: vaultEntry,
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
        expect(find.byType(Favicon), findsOneWidget);
        expect(
          find.byType(VaultListEntryPopup),
          isMobile ? findsOneWidget : findsNothing,
        );
        expect(find.text("my-name"), findsOneWidget);
        expect(find.text("my-user"), findsOneWidget);
      });

      testWidgets("Test tap ($deviceSize)", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntry(
              selected: false,
              isMobile: isMobile,
              entry: vaultEntry,
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        final detector =
            find
                    .byKey(ValueKey("entry-${vaultEntry.id}"))
                    .evaluate()
                    .first
                    .widget
                as GestureDetector;
        detector.onTap!();
        await tester.pumpAndSettle();

        if (isMobile) {
          expect(find.byType(VaultEntryDetailPage), findsOneWidget);
        } else {
          final container = ProviderScope.containerOf(
            tester.element(find.byType(VaultListEntry)),
          );
          expect(container.read(selectedEntryProvider), vaultEntry);
        }
      });

      testWidgets("Test long tap ($deviceSize)", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntry(
              selected: false,
              isMobile: isMobile,
              entry: vaultEntry,
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        final detector =
            find
                    .byKey(ValueKey("entry-${vaultEntry.id}"))
                    .evaluate()
                    .first
                    .widget
                as GestureDetector;
        detector.onLongPress!();
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsAny);
      });

      testWidgets("Test double tap ($deviceSize)", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntry(
              selected: false,
              isMobile: isMobile,
              entry: vaultEntry,
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        final detector =
            find
                    .byKey(ValueKey("entry-${vaultEntry.id}"))
                    .evaluate()
                    .first
                    .widget
                as GestureDetector;
        detector.onDoubleTap!();
        await tester.pumpAndSettle();

        if (isMobile) {
          expect(find.byType(AddEditVaultEntryPage), findsOneWidget);
        } else {
          final container = ProviderScope.containerOf(
            tester.element(find.byType(VaultListEntry)),
          );
          expect(container.read(selectedEntryProvider), vaultEntry);
          expect(container.read(addEditModeActiveProvider), true);
        }
      });

      testWidgets("Test secondary tap ($deviceSize)", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntry(
              selected: false,
              isMobile: isMobile,
              entry: vaultEntry,
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byType(ListTile), buttons: kSecondaryButton);
        await tester.pumpAndSettle();

        if (isMobile) {
          expect(find.byType(PopupMenuItem<PopupSelection>), findsNothing);
        } else {
          expect(find.byType(PopupMenuItem<PopupSelection>), findsAny);
        }
      });
    }
  });
}
