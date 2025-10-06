import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_list_entry_popup.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/test_error_suppression.dart';

void main() {
  group("VaultListEntryPopup", () {
    group("Note", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.note.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(3));
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

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

        expect(clicked, 3);
      });
    });

    group("API key", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.api.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(4));
        expect(find.text("Copy api key"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy api key"));
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

        expect(clicked, 4);
      });
    });

    group("Bank/Credit card", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.card.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(10));
        expect(find.text("Copy issuer"), findsOneWidget);
        expect(find.text("Copy holder name"), findsOneWidget);
        expect(find.text("Copy number"), findsOneWidget);
        expect(find.text("Copy expiration month"), findsOneWidget);
        expect(find.text("Copy expiration year"), findsOneWidget);
        expect(find.text("Copy security code"), findsOneWidget);
        expect(find.text("Copy PIN"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy issuer"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy holder name"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy number"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy expiration month"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy expiration year"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy security code"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy PIN"));
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

        expect(clicked, 10);
      });
    });

    group("Credentials", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.credential.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
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
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
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

    group("OAuth", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.oauth.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(7));
        expect(find.text("Copy access token"), findsOneWidget);
        expect(find.text("Copy refresh token"), findsOneWidget);
        expect(find.text("Copy client id"), findsOneWidget);
        expect(find.text("Copy provider"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy access token"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy refresh token"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy client id"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy provider"));
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

        expect(clicked, 7);
      });
    });

    group("PGP", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.pgp.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(6));
        expect(find.text("Copy public key"), findsOneWidget);
        expect(find.text("Copy private key"), findsOneWidget);
        expect(find.text("Copy fingerprint"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy public key"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy private key"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy fingerprint"));
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

    group("S/MIME", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.smime.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(5));
        expect(find.text("Copy certificate"), findsOneWidget);
        expect(find.text("Copy private key"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy certificate"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy private key"));
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

        expect(clicked, 5);
      });
    });

    group("SSH", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.ssh.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(6));
        expect(find.text("Copy private key"), findsOneWidget);
        expect(find.text("Copy public key"), findsOneWidget);
        expect(find.text("Copy fingerprint"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy public key"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy private key"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy fingerprint"));
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

    group("WiFi", () {
      final entry = VaultEntry.empty().copyWith(type: VaultEntryType.wifi.name);
      testWidgets("Test default elements", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.byType(PopupMenuButton<PopupSelection>), findsOneWidget);
        expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
      });

      testWidgets("Test popup entries", (tester) async {
        suppressOverflowErrors();
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(entry: entry, onSelected: (_, _) {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem<PopupSelection>), findsNWidgets(5));
        expect(find.text("Copy password"), findsOneWidget);
        expect(find.text("Copy SSID"), findsOneWidget);
        expect(find.text("Edit"), findsOneWidget);
        expect(find.text("View"), findsOneWidget);
        expect(find.text("Delete"), findsOneWidget);
      });

      testWidgets("Test callback", (tester) async {
        suppressOverflowErrors();
        int clicked = 0;
        final sut = Material(
          child: Scaffold(
            body: VaultListEntryPopup(
              entry: entry,
              onSelected: (_, _) {
                clicked++;
              },
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy password"));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(LucideIcons.ellipsis));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Copy SSID"));
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

        expect(clicked, 5);
      });
    });
  });
}
