import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';

void main() {
  group('VaultEntry factory constructors', () {
    test('credential', () {
      final e = VaultEntry.credential(
        id: 'id-cred',
        name: 'cred-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        username: 'user',
        password: 'pass',
        urls: ['https://example.com'],
      );

      expect(e.id, 'id-cred');
      expect(e.type, VaultEntryType.credential.name);
      expect(e.username, 'user');
      expect(e.password, 'pass');
      expect(e.urls, ['https://example.com']);

      // unrelated fields should be empty/default
      expect(e.sshPrivateKey, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.apiKey, isEmpty);
      expect(e.oauthAccessToken, isEmpty);
      expect(e.wifiSsid, isEmpty);
      expect(e.pgpPrivateKey, isEmpty);
      expect(e.smimePrivateKey, isEmpty);
    });

    test('ssh', () {
      final e = VaultEntry.ssh(
        id: 'id-ssh',
        name: 'ssh-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        sshPrivateKey: 'priv',
        sshPublicKey: 'pub',
        sshFingerprint: 'fp',
      );

      expect(e.id, 'id-ssh');
      expect(e.type, VaultEntryType.ssh.name);
      expect(e.sshPrivateKey, 'priv');
      expect(e.sshPublicKey, 'pub');
      expect(e.sshFingerprint, 'fp');

      expect(e.username, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.apiKey, isEmpty);
    });

    test('card', () {
      final e = VaultEntry.card(
        id: 'id-card',
        name: 'card-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        cardNumber: '4111111111111111',
        cardHolderName: 'Card Holder',
        cardIssuer: 'visa',
        cardExpirationMonth: '12',
        cardExpirationYear: '2030',
        cardSecurityCode: '123',
        cardPin: '0000',
      );

      expect(e.id, 'id-card');
      expect(e.type, VaultEntryType.card.name);
      expect(e.cardNumber, '4111111111111111');
      expect(e.cardHolderName, 'Card Holder');
      expect(e.cardIssuer, 'visa');
      expect(e.cardExpirationMonth, '12');
      expect(e.cardExpirationYear, '2030');
      expect(e.cardSecurityCode, '123');
      expect(e.cardPin, '0000');

      expect(e.username, isEmpty);
      expect(e.sshPrivateKey, isEmpty);
      expect(e.apiKey, isEmpty);
    });

    test('oauth', () {
      final e = VaultEntry.oauth(
        id: 'id-oauth',
        name: 'oauth-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        oauthAccessToken: 'atoken',
        oauthClientId: 'cid',
        oauthProvider: 'provider',
        oauthRefreshToken: 'rtoken',
      );

      expect(e.id, 'id-oauth');
      expect(e.type, VaultEntryType.oauth.name);
      expect(e.oauthAccessToken, 'atoken');
      expect(e.oauthClientId, 'cid');
      expect(e.oauthProvider, 'provider');
      expect(e.oauthRefreshToken, 'rtoken');

      expect(e.username, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.apiKey, isEmpty);
    });

    test('api', () {
      final e = VaultEntry.api(
        id: 'id-api',
        name: 'api-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        apiKey: 'apikey-123',
      );

      expect(e.id, 'id-api');
      expect(e.type, VaultEntryType.api.name);
      expect(e.apiKey, 'apikey-123');

      expect(e.username, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.sshPrivateKey, isEmpty);
    });

    test('wifi', () {
      final e = VaultEntry.wifi(
        id: 'id-wifi',
        name: 'wifi-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        wifiSsid: 'MySSID',
        wifiPassword: 'wifipass',
      );

      expect(e.id, 'id-wifi');
      expect(e.type, VaultEntryType.wifi.name);
      expect(e.wifiSsid, 'MySSID');
      expect(e.wifiPassword, 'wifipass');

      expect(e.username, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.apiKey, isEmpty);
    });

    test('pgp', () {
      final e = VaultEntry.pgp(
        id: 'id-pgp',
        name: 'pgp-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        pgpPrivateKey: 'priv-pgp',
        pgpPublicKey: 'pub-pgp',
        pgpFingerprint: 'fp-pgp',
      );

      expect(e.id, 'id-pgp');
      expect(e.type, VaultEntryType.pgp.name);
      expect(e.pgpPrivateKey, 'priv-pgp');
      expect(e.pgpPublicKey, 'pub-pgp');
      expect(e.pgpFingerprint, 'fp-pgp');

      expect(e.username, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.apiKey, isEmpty);
    });

    test('smime', () {
      final e = VaultEntry.smime(
        id: 'id-smime',
        name: 'smime-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        smimePrivateKey: 'priv-smime',
        smimeCertificate: 'cert-smime',
      );

      expect(e.id, 'id-smime');
      expect(e.type, VaultEntryType.smime.name);
      expect(e.smimePrivateKey, 'priv-smime');
      expect(e.smimeCertificate, 'cert-smime');

      expect(e.username, isEmpty);
      expect(e.cardNumber, isEmpty);
      expect(e.apiKey, isEmpty);
    });
  });

  group('VaultEntry serialization and crypto', () {
    test('toJson/fromJson roundtrip preserves fields', () {
      final original = VaultEntry.credential(
        id: 'r-id',
        name: 'round-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        username: 'user',
        password: 'pass',
        urls: ['https://example.com'],
      );

      final json = original.toJson();
      final restored = VaultEntry.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.username, original.username);
      expect(restored.password, original.password);
      expect(restored.urls, original.urls);
    });

    test('encrypt/decrypt roundtrip returns original values', () async {
      final original = VaultEntry.api(
        id: 'e-id',
        name: 'enc-name',
        createdAt: 'ca',
        updatedAt: 'ua',
        comments: 'c',
        folder: 'f',
        apiKey: 'apikey',
      );

      // simple fake encrypt/decrypt for test
      Future<String> fakeEncrypt(String s) async => 'ENC:$s';
      Future<String> fakeDecrypt(String s) async {
        if (s.startsWith('ENC:')) return s.substring(4);
        throw StateError('Not encrypted');
      }

      final enc = await original.encrypt(fakeEncrypt);
      // encrypted fields should not equal original
      expect(enc.apiKey, isNot(equals(original.apiKey)));

      final dec = await enc.decrypt(fakeDecrypt);
      expect(dec.apiKey, original.apiKey);
      expect(dec.id, original.id);
    });
  });
}
