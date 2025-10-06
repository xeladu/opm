import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:open_password_manager/features/vault/domain/entities/card_issuer.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/add_edit_form.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../helper/app_setup.dart';
import '../../../../helper/test_data_generator.dart';
import '../../../../mocking/mocks.mocks.dart';

void main() {
  group("AddEditForm", () {
    late MockVaultRepository mockVaultRepository;
    late MockStorageService mockStorageService;
    late MockCryptographyRepository mockCryptographyRepository;

    setUp(() {
      mockVaultRepository = MockVaultRepository();
      mockStorageService = MockStorageService();
      mockCryptographyRepository = MockCryptographyRepository();
    });

    for (final type in VaultEntryType.values) {
      testWidgets("Test add form for type '${type.toNiceString()}'", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: AddEditForm(template: type, onCancel: () {}, onSave: () {}),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        switch (type) {
          case VaultEntryType.note:
            expect(find.byType(ShadInputFormField), findsNWidgets(2));
          case VaultEntryType.credential:
            expect(find.byType(ShadInputFormField), findsNWidgets(5));
          case VaultEntryType.card:
            expect(find.byType(ShadInputFormField), findsNWidgets(6));
            expect(find.byType(ShadSelectFormField<CardIssuer>), findsNWidgets(1));
            expect(find.byType(ShadSelectFormField<int>), findsNWidgets(2));
          case VaultEntryType.ssh:
            expect(find.byType(ShadInputFormField), findsNWidgets(5));
          case VaultEntryType.api:
            expect(find.byType(ShadInputFormField), findsNWidgets(3));
          case VaultEntryType.oauth:
            expect(find.byType(ShadInputFormField), findsNWidgets(6));
          case VaultEntryType.wifi:
            expect(find.byType(ShadInputFormField), findsNWidgets(4));
          case VaultEntryType.pgp:
            expect(find.byType(ShadInputFormField), findsNWidgets(5));
          case VaultEntryType.smime:
            expect(find.byType(ShadInputFormField), findsNWidgets(4));
        }
      });

      testWidgets("Test edit form for type '${type.toNiceString()}'", (tester) async {
        final sut = Material(
          child: Scaffold(
            body: AddEditForm(
              template: type,
              entry: VaultEntry.empty().copyWith(
                name: "my-name",
                username: "my-user",
                password: "my-pass",
                urls: ["url1", "url2"],
                folder: "my-folder",
                apiKey: "my-api-key",
                cardExpirationMonth: "2",
                cardExpirationYear: "1999",
                cardHolderName: "my-card-holder",
                cardIssuer: CardIssuer.visa.name,
                cardNumber: "my-card-number",
                cardPin: "my-card-pin",
                cardSecurityCode: "my-card-security-code",
                comments: "my-comments",
                oauthAccessToken: "my-oauth-access-token",
                oauthRefreshToken: "my-oauth-refresh-token",
                oauthClientId: "my-oauth-client-id",
                oauthProvider: "my-oauth-provider",
                pgpFingerprint: "my-pgp-fingerprint",
                pgpPrivateKey: "my-pgp-private-key",
                pgpPublicKey: "my-pgp-public-key",
                smimeCertificate: "my-smime-certificate",
                smimePrivateKey: "my-smime-private-key",
                sshFingerprint: "my-ssh-fingerprint",
                sshPrivateKey: "my-ssh-private-key",
                sshPublicKey: "my-ssh-public-key",
                wifiPassword: "my-wifi-pass",
                wifiSsid: "my-wifi-ssid",
              ),
              onCancel: () {},
              onSave: () {},
            ),
          ),
        );
        await AppSetup.pumpPage(tester, sut, []);

        expect(find.text("my-comments"), findsOneWidget);
        expect(find.text("my-name"), findsOneWidget);
        expect(find.text("my-folder"), findsOneWidget);

        switch (type) {
          case VaultEntryType.note:
            expect(find.byType(ShadInputFormField), findsNWidgets(2));
          case VaultEntryType.credential:
            expect(find.byType(ShadInputFormField), findsNWidgets(5));
            expect(find.byIcon(LucideIcons.packagePlus), findsOneWidget);
            expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
            expect(find.text("my-user"), findsOneWidget);
            expect(find.text("my-pass"), findsOneWidget);
            expect(find.textContaining("url1"), findsOneWidget);
            expect(find.textContaining("url2"), findsOneWidget);
          case VaultEntryType.card:
            expect(find.byType(ShadInputFormField), findsNWidgets(6));
            expect(find.byType(ShadSelectFormField<CardIssuer>), findsNWidgets(1));
            expect(find.byType(ShadSelectFormField<int>), findsNWidgets(2));
            expect(find.byIcon(LucideIcons.eyeOff), findsNWidgets(2));
            expect(find.text("2"), findsOneWidget);
            expect(find.text("1999"), findsOneWidget);
            expect(find.text("my-card-pin"), findsOneWidget);
            expect(find.text("my-card-number"), findsOneWidget);
            expect(find.text("my-card-holder"), findsOneWidget);
            expect(find.text("my-card-security-code"), findsOneWidget);
            expect(find.text("VISA"), findsOneWidget);
          case VaultEntryType.ssh:
            expect(find.byType(ShadInputFormField), findsNWidgets(5));
            expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
            expect(find.text("my-ssh-private-key"), findsOneWidget);
            expect(find.text("my-ssh-public-key"), findsOneWidget);
            expect(find.text("my-ssh-fingerprint"), findsOneWidget);
          case VaultEntryType.api:
            expect(find.byType(ShadInputFormField), findsNWidgets(3));
            expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
            expect(find.text("my-api-key"), findsOneWidget);
          case VaultEntryType.oauth:
            expect(find.byType(ShadInputFormField), findsNWidgets(6));
            expect(find.byIcon(LucideIcons.eyeOff), findsNWidgets(2));
            expect(find.text("my-oauth-access-token"), findsOneWidget);
            expect(find.text("my-oauth-refresh-token"), findsOneWidget);
            expect(find.text("my-oauth-provider"), findsOneWidget);
            expect(find.text("my-oauth-client-id"), findsOneWidget);
          case VaultEntryType.wifi:
            expect(find.byType(ShadInputFormField), findsNWidgets(4));
            expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
            expect(find.text("my-wifi-pass"), findsOneWidget);
            expect(find.text("my-wifi-ssid"), findsOneWidget);
          case VaultEntryType.pgp:
            expect(find.byType(ShadInputFormField), findsNWidgets(5));
            expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
            expect(find.text("my-pgp-private-key"), findsOneWidget);
            expect(find.text("my-pgp-public-key"), findsOneWidget);
            expect(find.text("my-pgp-fingerprint"), findsOneWidget);
          case VaultEntryType.smime:
            expect(find.byType(ShadInputFormField), findsNWidgets(4));
            expect(find.byIcon(LucideIcons.eyeOff), findsNWidgets(2));
            expect(find.text("my-smime-private-key"), findsOneWidget);
            expect(find.text("my-smime-certificate"), findsOneWidget);
        }
      });
    }

    testWidgets("Test change folder", (tester) async {
      when(mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate"))).thenAnswer(
        (_) => Future.value([
          TestDataGenerator.vaultEntry(folder: "folder1"),
          TestDataGenerator.vaultEntry(folder: "folder2"),
        ]),
      );
      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            template: VaultEntryType.credential,
            entry: TestDataGenerator.vaultEntry(),
            onCancel: () {},
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
      ]);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));
      expect(find.text("my-name"), findsOneWidget);
      expect(find.text("my-user"), findsOneWidget);
      expect(find.text("my-pass"), findsOneWidget);
      expect(find.textContaining("url1"), findsOneWidget);
      expect(find.textContaining("url2"), findsOneWidget);
      expect(find.text("my-folder"), findsOneWidget);

      // TODO This test does not trigger the selection dropdown

      expect(find.byType(ShadSelectFormField<String>), findsOneWidget);
      await tester.tap(find.byType(ShadSelectFormField<String>));
      await tester.pumpAndSettle();

      expect(find.byType(ShadOption<String>), findsNWidgets(3));
      await tester.tap(find.byType(ShadOption<String>).last);
      await tester.pumpAndSettle();

      expect(find.text("folder2"), findsOneWidget);
      expect(find.text("my-folder"), findsNothing);
    }, skip: true);

    testWidgets("Test invalid save", (tester) async {
      bool saved = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            template: VaultEntryType.credential,
            onCancel: () {},
            onSave: () {
              saved = true;
            },
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
      expect(find.text("Required"), findsOneWidget);
    });

    testWidgets("Test save", (tester) async {
      bool saved = false;

      when(
        mockVaultRepository.getAllEntries(onUpdate: anyNamed("onUpdate")),
      ).thenAnswer((_) => Future.value([TestDataGenerator.randomVaultEntry()]));
      when(mockCryptographyRepository.encrypt(any)).thenAnswer((_) => Future.value("encrypted"));

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            template: VaultEntryType.credential,
            onCancel: () {},
            onSave: () {
              saved = true;
            },
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, [
        vaultRepositoryProvider.overrideWithValue(mockVaultRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        cryptographyRepositoryProvider.overrideWithValue(mockCryptographyRepository),
      ]);

      when(mockVaultRepository.addEntry(any)).thenAnswer((_) => Future.value());

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.enterText(find.byType(ShadInputFormField).first, "Test");
      await tester.pumpAndSettle();

      expect(find.byType(ShadBadge), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(saved, isTrue);
    });

    testWidgets("Test cancel", (tester) async {
      bool cancel = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            template: VaultEntryType.credential,
            onCancel: () {
              cancel = true;
            },
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      expect(cancel, isTrue);
    });

    testWidgets("Test cancel with confirmation", (tester) async {
      bool cancel = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            template: VaultEntryType.credential,
            onCancel: () {
              cancel = true;
            },
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.enterText(find.byType(ShadInputFormField).first, "Test");
      await tester.pumpAndSettle();

      expect(find.byType(ShadBadge), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Leave"));
      await tester.pumpAndSettle();

      expect(cancel, isTrue);
    });

    testWidgets("Test cancel with rejected confirmation", (tester) async {
      bool cancel = false;

      final sut = Material(
        child: Scaffold(
          body: AddEditForm(
            template: VaultEntryType.credential,
            onCancel: () {
              cancel = true;
            },
            onSave: () {},
          ),
        ),
      );
      await AppSetup.pumpPage(tester, sut, []);

      expect(find.byType(ShadInputFormField), findsNWidgets(5));

      await tester.enterText(find.byType(ShadInputFormField).first, "Test");
      await tester.pumpAndSettle();

      expect(find.byType(ShadBadge), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Stay"));
      await tester.pumpAndSettle();

      expect(cancel, isFalse);
    });
  });
}
