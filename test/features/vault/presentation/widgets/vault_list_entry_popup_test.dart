import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry_popup.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("VaultListEntryPopup", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListEntryPopup(
            entry: VaultEntry.empty(),
            onSelected: (_, _) {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
    });

    testWidgets("Test popup entries", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultListEntryPopup(
            entry: VaultEntry.empty(),
            onSelected: (_, _) {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(6));
      expect(find.text("Copy username"), findsOneWidget);
      expect(find.text("Copy password"), findsOneWidget);
      expect(find.text("Open URL"), findsOneWidget);
      expect(find.text("Edit"), findsOneWidget);
      expect(find.text("View"), findsOneWidget);
      expect(find.text("Delete"), findsOneWidget);
    });

    testWidgets("Test callback", (tester) async {
      int clicked = 0;
      final sut = Material(
        child: Scaffold(
          body: VaultListEntryPopup(
            entry: VaultEntry.empty(),
            onSelected: (_, _) {
              clicked++;
            },
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Copy username"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Copy password"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Open URL"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      await tester.tap(find.text("View"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Edit"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.ellipsis));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();

      expect(clicked, 6);
    });
  });
}
