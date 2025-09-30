import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/domain/entities/card_issuer.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/shared/presentation/inputs/plain_text_form_field.dart';

import '../../../../helper/app_setup.dart';

void main() {
  group("VaultEntryDetails", () {
    testWidgets("Test default elements for type '${VaultEntryType.credential.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.credential(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              username: "my-user",
              password: "my-pass",
              urls: ["url1", "url2"],
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(8));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsOneWidget);
      expect(find.textContaining("url1"), findsOneWidget);
      expect(find.textContaining("url2"), findsOneWidget);
      expect(find.text("my-user"), findsOneWidget);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.note.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.note(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(5));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.api.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.api(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              apiKey: "my-key",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(6));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsOneWidget);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.ssh.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.ssh(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              sshPrivateKey: "my-ssh-private-key",
              sshPublicKey: "my-ssh-public-key",
              sshFingerprint: "my-ssh-fingerprint",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(8));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsOneWidget);
      expect(find.text("my-ssh-public-key"), findsOneWidget);
      expect(find.text("my-ssh-fingerprint"), findsOneWidget);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.card.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.card(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              cardExpirationMonth: "2",
              cardExpirationYear: "1999",
              cardHolderName: "my-card-holder",
              cardIssuer: CardIssuer.visa.name,
              cardNumber: "my-card-number",
              cardPin: "my-card-pin",
              cardSecurityCode: "my-card-security-code",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(11));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsOneWidget);
      expect(find.text("my-card-holder"), findsOneWidget);
      expect(find.text("VISA"), findsOneWidget);
      expect(find.text("my-card-number"), findsOneWidget);
      expect(find.text("my-card-pin"), findsOneWidget);
      expect(find.text("my-card-security-code"), findsOneWidget);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.oauth.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.oauth(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              oauthAccessToken: "my-access-token",
              oauthRefreshToken: "my-refresh-token",
              oauthClientId: "my-client-id",
              oauthProvider: "my-provider",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(9));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsOneWidget);
      expect(find.text("my-refresh-token"), findsOneWidget);
      expect(find.text("my-client-id"), findsOneWidget);
      expect(find.text("my-provider"), findsOneWidget);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.pgp.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.pgp(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              pgpPrivateKey: "my-pgp-private-key",
              pgpPublicKey: "my-pgp-public-key",
              pgpFingerprint: "my-pgp-fingerprint",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(8));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsOneWidget);
      expect(find.text("my-pgp-public-key"), findsOneWidget);
      expect(find.text("my-pgp-fingerprint"), findsOneWidget);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.smime.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.smime(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              smimePrivateKey: "my-smime-private-key",
              smimeCertificate: "my-smime-certificate",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(7));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsOneWidget);
      expect(find.text("my-smime-certificate"), findsOneWidget);

      // Wifi
      expect(find.text("my-wifi-pass"), findsNothing);
      expect(find.text("my-wifi-ssid"), findsNothing);
    });

    testWidgets("Test default elements for type '${VaultEntryType.wifi.toNiceString()}'", (
      tester,
    ) async {
      final sut = Material(
        child: Scaffold(
          body: VaultEntryDetails(
            entry: VaultEntry.wifi(
              id: "my-id",
              name: "my-name",
              createdAt: DateTime(2020, 1, 1, 1, 1, 1).toIso8601String(),
              updatedAt: DateTime(2021, 1, 1, 1, 1, 1).toIso8601String(),
              comments: "my-comments",
              folder: "my-folder",
              wifiPassword: "my-wifi-pass",
              wifiSsid: "my-wifi-ssid",
            ),
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(PlainTextFormField), findsNWidgets(7));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-comments"), findsOneWidget);
      expect(find.textContaining("2020/01/01, 01:01:01"), findsOneWidget);
      expect(find.textContaining("2021/01/01, 01:01:01"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // credential
      expect(find.text("my-pass"), findsNothing);
      expect(find.textContaining("url1"), findsNothing);
      expect(find.textContaining("url2"), findsNothing);
      expect(find.text("my-user"), findsNothing);

      // note
      // already checked

      // api
      expect(find.text("my-key"), findsNothing);

      // ssh
      expect(find.text("my-ssh-private-key"), findsNothing);
      expect(find.text("my-ssh-public-key"), findsNothing);
      expect(find.text("my-ssh-fingerprint"), findsNothing);

      // card
      expect(find.text("2 / 1999"), findsNothing);
      expect(find.text("my-card-holder"), findsNothing);
      expect(find.text("VISA"), findsNothing);
      expect(find.text("my-card-number"), findsNothing);
      expect(find.text("my-card-pin"), findsNothing);
      expect(find.text("my-card-security-code"), findsNothing);

      // OAuth
      expect(find.text("my-access-token"), findsNothing);
      expect(find.text("my-refresh-token"), findsNothing);
      expect(find.text("my-client-id"), findsNothing);
      expect(find.text("my-provider"), findsNothing);

      // PGP
      expect(find.text("my-pgp-private-key"), findsNothing);
      expect(find.text("my-pgp-public-key"), findsNothing);
      expect(find.text("my-pgp-fingerprint"), findsNothing);

      // S-MIME
      expect(find.text("my-smime-private-key"), findsNothing);
      expect(find.text("my-smime-certificate"), findsNothing);

      // Wifi
      expect(find.text("my-wifi-pass"), findsOneWidget);
      expect(find.text("my-wifi-ssid"), findsOneWidget);
    });
  });
}
