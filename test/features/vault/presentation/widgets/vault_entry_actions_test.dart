import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_actions.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("VaultEntryActions", () {
    testWidgets("Test default elements", (tester) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryActions(
            onDuplicate: () {},
            onEdit: () {},
            onDelete: () {},
            enabled: true,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(GlyphButton), findsNWidgets(3));
    });

    testWidgets("Test actions", (tester) async {
      int clicked = 0;
      final sut = Material(
        child: Scaffold(
          body: VaultEntryActions(
            onDuplicate: () {
              clicked++;
            },
            onEdit: () {
              clicked++;
            },
            onDelete: () {
              clicked++;
            },
            enabled: true,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      await tester.tap(find.byIcon(LucideIcons.pen));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.copy));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.trash, skipOffstage: false));
      await tester.pumpAndSettle();

      expect(clicked, 3);
    });

    testWidgets("Test actions when disabled", (tester) async {
      int clicked = 0;
      final sut = Material(
        child: Scaffold(
          body: VaultEntryActions(
            onDuplicate: () {
              clicked++;
            },
            onEdit: () {
              clicked++;
            },
            onDelete: () {
              clicked++;
            },
            enabled: false,
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      try {
        await tester.tap(find.byIcon(LucideIcons.pen, skipOffstage: false));
      } on Error catch (e) {
        expect(e, isA<FlutterError>());
      }

      try {
        await tester.tap(find.byIcon(LucideIcons.copy, skipOffstage: false));
      } on Error catch (e) {
        expect(e, isA<FlutterError>());
      }

      try {
        await tester.tap(find.byIcon(LucideIcons.trash, skipOffstage: false));
      } on Error catch (e) {
        expect(e, isA<FlutterError>());
      }

      expect(clicked, 0);
    });
  });
}
