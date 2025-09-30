import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/card_issuer.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/shared/presentation/sheets/entry_filter_sheet.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helper/app_setup.dart';
import '../../../mocking/fakes.dart';

void main() {
  group("EntryFilterSheet", () {
    testWidgets("Test default elements", (tester) async {
      final sut = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text("Sheet me!"),
              onPressed: () =>
                  showShadSheet(builder: (context) => EntryFilterSheet(), context: context),
            ),
          ),
        ),
      );

      await tester.runAsync(
        () async => await AppSetup.pumpPage(tester, sut, [
          allEntriesProvider.overrideWith(
            () => FakeAllEntriesState([
              VaultEntry.note(
                id: "id-note",
                name: "name-note",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-note",
                folder: "Test folder",
              ),
              VaultEntry.api(
                id: "id-api",
                name: "name-api",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-api",
                folder: "Dummy folder",
                apiKey: "api",
              ),
              VaultEntry.credential(
                id: "id-cred",
                name: "name-cred",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-cred",
                folder: "",
                username: "user",
                password: "pass",
                urls: ["url1"],
              ),
              VaultEntry.card(
                id: "id-card",
                name: "name-card",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-card",
                folder: "",
                cardExpirationMonth: "8",
                cardExpirationYear: "1999",
                cardHolderName: "my-card-holder",
                cardIssuer: CardIssuer.americanExpress.name,
                cardNumber: "123",
                cardPin: "246",
                cardSecurityCode: "333",
              ),
              VaultEntry.oauth(
                id: "id-oauth",
                name: "name-oauth",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-oauth",
                folder: "",
                oauthAccessToken: "at",
                oauthClientId: "ci",
                oauthProvider: "p",
                oauthRefreshToken: "rt",
              ),
              VaultEntry.pgp(
                id: "id-pgp",
                name: "name-pgp",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-pgp",
                folder: "",
                pgpFingerprint: "f",
                pgpPrivateKey: "p",
                pgpPublicKey: "p",
              ),
              VaultEntry.ssh(
                id: "id-ssh",
                name: "name-ssh",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-ssh",
                folder: "",
                sshFingerprint: "f",
                sshPrivateKey: "p",
                sshPublicKey: "p",
              ),
              VaultEntry.smime(
                id: "id-smime",
                name: "name-smime",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-smime",
                folder: "",
                smimeCertificate: "f",
                smimePrivateKey: "p",
              ),
              VaultEntry.wifi(
                id: "id-smime",
                name: "name-smime",
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                comments: "comments-smime",
                folder: "",
                wifiPassword: "f",
                wifiSsid: "p",
              ),
            ]),
          ),
        ]),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFilterSheet), findsOneWidget);
      expect(find.byType(TypeFolderSection), findsOneWidget);

      for (final type in VaultEntryType.values) {
        expect(find.text(type.toNiceString()), findsOneWidget);
      }

      expect(find.byType(CustomFolderSection), findsOneWidget);
      expect(find.text("All entries"), findsOneWidget);
      expect(find.text("Dummy folder"), findsOneWidget);
      expect(find.text("Test folder"), findsOneWidget);

      expect(find.text("Close"), findsOneWidget);
    });
  });
}
