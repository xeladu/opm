import 'package:equatable/equatable.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';

class VaultEntry extends Equatable {
  // common fields
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final String comments;
  final String folder;
  final String type;

  // Credential
  final String username;
  final String password;
  final List<String> urls;

  // SSH
  final String sshPrivateKey;
  final String sshPublicKey;
  final String sshFingerprint;

  // Card
  final String cardHolderName;
  final String cardNumber;
  final String cardExpirationMonth;
  final String cardExpirationYear;
  final String cardSecurityCode;
  final String cardIssuer;
  final String cardPin;

  // API
  final String apiKey;

  // OAuth
  final String oauthProvider;
  final String oauthClientId;
  final String oauthAccessToken;
  final String oauthRefreshToken;

  // Wifi
  final String wifiSsid;
  final String wifiPassword;

  // PGP
  final String pgpPrivateKey;
  final String pgpPublicKey;
  final String pgpFingerprint;

  // S-MIME
  final String smimeCertificate;
  final String smimePrivateKey;

  const VaultEntry._({
    required this.type,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    required this.folder,

    // Credential
    required this.username,
    required this.password,
    required this.urls,

    // SSH
    required this.sshPrivateKey,
    required this.sshPublicKey,
    required this.sshFingerprint,

    // Card
    required this.cardHolderName,
    required this.cardNumber,
    required this.cardExpirationMonth,
    required this.cardExpirationYear,
    required this.cardSecurityCode,
    required this.cardIssuer,
    required this.cardPin,

    // API
    required this.apiKey,

    // OAuth
    required this.oauthProvider,
    required this.oauthClientId,
    required this.oauthAccessToken,
    required this.oauthRefreshToken,

    // Wifi
    required this.wifiSsid,
    required this.wifiPassword,

    // PGP
    required this.pgpPrivateKey,
    required this.pgpPublicKey,
    required this.pgpFingerprint,

    // S-MIME
    required this.smimeCertificate,
    required this.smimePrivateKey,
  });

  factory VaultEntry.note({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.note.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
    );
  }

  factory VaultEntry.credential({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String username,
    required String password,
    required List<String> urls,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.credential.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      username: username,
      password: password,
      urls: urls,
    );
  }

  factory VaultEntry.ssh({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String sshPrivateKey,
    required String sshPublicKey,
    required String sshFingerprint,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.ssh.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      sshPrivateKey: sshPrivateKey,
      sshPublicKey: sshPublicKey,
      sshFingerprint: sshFingerprint,
    );
  }

  factory VaultEntry.card({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String cardNumber,
    required String cardHolderName,
    required String cardIssuer,
    required String cardExpirationMonth,
    required String cardExpirationYear,
    required String cardSecurityCode,
    required String cardPin,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.card.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      cardNumber: cardNumber,
      cardHolderName: cardHolderName,
      cardIssuer: cardIssuer,
      cardExpirationMonth: cardExpirationMonth,
      cardExpirationYear: cardExpirationYear,
      cardSecurityCode: cardSecurityCode,
      cardPin: cardPin,
    );
  }

  factory VaultEntry.oauth({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String oauthAccessToken,
    required String oauthClientId,
    required String oauthProvider,
    required String oauthRefreshToken,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.oauth.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      oauthAccessToken: oauthAccessToken,
      oauthClientId: oauthClientId,
      oauthProvider: oauthProvider,
      oauthRefreshToken: oauthRefreshToken,
    );
  }

  factory VaultEntry.api({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String apiKey,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.api.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      apiKey: apiKey,
    );
  }

  factory VaultEntry.wifi({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String wifiSsid,
    required String wifiPassword,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.wifi.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      wifiSsid: wifiSsid,
      wifiPassword: wifiPassword,
    );
  }

  factory VaultEntry.pgp({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String pgpPrivateKey,
    required String pgpPublicKey,
    required String pgpFingerprint,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.pgp.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      pgpPrivateKey: pgpPrivateKey,
      pgpPublicKey: pgpPublicKey,
      pgpFingerprint: pgpFingerprint,
    );
  }

  factory VaultEntry.smime({
    required String id,
    required String name,
    required String createdAt,
    required String updatedAt,
    required String comments,
    required String folder,
    required String smimePrivateKey,
    required String smimeCertificate,
  }) {
    return VaultEntry.empty().copyWith(
      id: id,
      type: VaultEntryType.smime.name,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      folder: folder,
      smimePrivateKey: smimePrivateKey,
      smimeCertificate: smimeCertificate,
    );
  }

  VaultEntry.empty()
    : this._(
        type: '',
        id: '',
        name: '',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        comments: '',
        folder: '',

        // Credential
        username: '',
        password: '',
        urls: const [],

        // SSH
        sshPrivateKey: '',
        sshPublicKey: '',
        sshFingerprint: '',

        // Card
        cardHolderName: '',
        cardNumber: '',
        cardIssuer: '',
        cardExpirationMonth: '',
        cardExpirationYear: '',
        cardPin: '',
        cardSecurityCode: '',

        // API
        apiKey: '',

        // OAuth
        oauthProvider: '',
        oauthClientId: '',
        oauthAccessToken: '',
        oauthRefreshToken: '',

        // Wifi
        wifiSsid: '',
        wifiPassword: '',

        // PGP
        pgpPrivateKey: '',
        pgpPublicKey: '',
        pgpFingerprint: '',

        // S-MIME
        smimeCertificate: '',
        smimePrivateKey: '',
      );

  VaultEntry copyWith({
    String? id,
    String? type,
    String? name,
    String? createdAt,
    String? updatedAt,
    String? username,
    String? password,
    List<String>? urls,
    String? comments,
    String? folder,
    String? sshPrivateKey,
    String? sshPublicKey,
    String? sshFingerprint,
    String? cardHolderName,
    String? cardNumber,
    String? cardExpirationMonth,
    String? cardExpirationYear,
    String? cardSecurityCode,
    String? cardIssuer,
    String? cardPin,
    String? apiKey,
    String? oauthProvider,
    String? oauthClientId,
    String? oauthAccessToken,
    String? oauthRefreshToken,
    String? wifiSsid,
    String? wifiPassword,
    String? pgpPrivateKey,
    String? pgpPublicKey,
    String? pgpFingerprint,
    String? smimeCertificate,
    String? smimePrivateKey,
  }) {
    return VaultEntry._(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      password: password ?? this.password,
      urls: urls ?? this.urls,
      comments: comments ?? this.comments,
      folder: folder ?? this.folder,
      sshPrivateKey: sshPrivateKey ?? this.sshPrivateKey,
      sshPublicKey: sshPublicKey ?? this.sshPublicKey,
      sshFingerprint: sshFingerprint ?? this.sshFingerprint,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpirationMonth: cardExpirationMonth ?? this.cardExpirationMonth,
      cardExpirationYear: cardExpirationYear ?? this.cardExpirationYear,
      cardSecurityCode: cardSecurityCode ?? this.cardSecurityCode,
      cardIssuer: cardIssuer ?? this.cardIssuer,
      cardPin: cardPin ?? this.cardPin,
      apiKey: apiKey ?? this.apiKey,
      oauthProvider: oauthProvider ?? this.oauthProvider,
      oauthClientId: oauthClientId ?? this.oauthClientId,
      oauthAccessToken: oauthAccessToken ?? this.oauthAccessToken,
      oauthRefreshToken: oauthRefreshToken ?? this.oauthRefreshToken,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      pgpPrivateKey: pgpPrivateKey ?? this.pgpPrivateKey,
      pgpPublicKey: pgpPublicKey ?? this.pgpPublicKey,
      pgpFingerprint: pgpFingerprint ?? this.pgpFingerprint,
      smimeCertificate: smimeCertificate ?? this.smimeCertificate,
      smimePrivateKey: smimePrivateKey ?? this.smimePrivateKey,
    );
  }

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry._(
      type: json.containsKey('type') && json['type'] is String ? json['type'] : '',
      id: json.containsKey('id') && json['id'] is String ? json['id'] : '',
      name: json.containsKey('name') && json['name'] is String ? json['name'] : '',
      createdAt: json.containsKey('created_at') && json['created_at'] is String
          ? json['created_at']
          : DateTime.now().toIso8601String(),
      updatedAt: json.containsKey('updated_at') && json['updated_at'] is String
          ? json['updated_at']
          : DateTime.now().toIso8601String(),
      comments: json.containsKey('comments') && json['comments'] is String ? json['comments'] : '',
      folder: json.containsKey('folder') && json['folder'] is String ? json['folder'] : '',

      // Credential
      username: json.containsKey('username') && json['username'] is String ? json['username'] : '',
      password: json.containsKey('password') && json['password'] is String ? json['password'] : '',
      urls: json.containsKey('urls') && json['urls'] is List
          ? List<String>.from(json['urls'].whereType<String>())
          : const [],

      // SSH
      sshPrivateKey: json.containsKey('ssh_private_key') && json['ssh_private_key'] is String
          ? json['ssh_private_key']
          : '',
      sshPublicKey: json.containsKey('ssh_public_key') && json['ssh_public_key'] is String
          ? json['ssh_public_key']
          : '',
      sshFingerprint: json.containsKey('ssh_fingerprint') && json['ssh_fingerprint'] is String
          ? json['ssh_fingerprint']
          : '',

      // Card
      cardHolderName: json.containsKey('card_holder_name') && json['card_holder_name'] is String
          ? json['card_holder_name']
          : '',
      cardNumber: json.containsKey('card_number') && json['card_number'] is String
          ? json['card_number']
          : '',
      cardExpirationMonth:
          json.containsKey('card_expiration_month') && json['card_expiration_month'] is String
          ? json['card_expiration_month']
          : '1',
      cardExpirationYear:
          json.containsKey('card_expiration_year') && json['card_expiration_year'] is String
          ? json['card_expiration_year']
          : '2020',
      cardSecurityCode:
          json.containsKey('card_security_code') && json['card_security_code'] is String
          ? json['card_security_code']
          : '',
      cardIssuer: json.containsKey('card_issuer') && json['card_issuer'] is String
          ? json['card_issuer']
          : '',
      cardPin: json.containsKey('card_pin') && json['card_pin'] is String ? json['card_pin'] : '',

      // API
      apiKey: json.containsKey('api_key') && json['api_key'] is String ? json['api_key'] : '',

      // OAuth
      oauthProvider: json.containsKey('oauth_provider') && json['oauth_provider'] is String
          ? json['oauth_provider']
          : '',
      oauthClientId: json.containsKey('oauth_client_id') && json['oauth_client_id'] is String
          ? json['oauth_client_id']
          : '',
      oauthAccessToken:
          json.containsKey('oauth_access_token') && json['oauth_access_token'] is String
          ? json['oauth_access_token']
          : '',
      oauthRefreshToken:
          json.containsKey('oauth_refresh_token') && json['oauth_refresh_token'] is String
          ? json['oauth_refresh_token']
          : '',

      // Wifi
      wifiSsid: json.containsKey('wifi_ssid') && json['wifi_ssid'] is String
          ? json['wifi_ssid']
          : '',
      wifiPassword: json.containsKey('wifi_password') && json['wifi_password'] is String
          ? json['wifi_password']
          : '',

      // PGP
      pgpPrivateKey: json.containsKey('pgp_private_key') && json['pgp_private_key'] is String
          ? json['pgp_private_key']
          : '',
      pgpPublicKey: json.containsKey('pgp_public_key') && json['pgp_public_key'] is String
          ? json['pgp_public_key']
          : '',
      pgpFingerprint: json.containsKey('pgp_fingerprint') && json['pgp_fingerprint'] is String
          ? json['pgp_fingerprint']
          : '',

      // S-MIME
      smimeCertificate: json.containsKey('smime_certificate') && json['smime_certificate'] is String
          ? json['smime_certificate']
          : '',
      smimePrivateKey: json.containsKey('smime_private_key') && json['smime_private_key'] is String
          ? json['smime_private_key']
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'comments': comments,
      'folder': folder,

      // Credential
      'username': username,
      'password': password,
      'urls': urls,

      // SSH
      'ssh_private_key': sshPrivateKey,
      'ssh_public_key': sshPublicKey,
      'ssh_fingerprint': sshFingerprint,

      // Card
      'card_holder_name': cardHolderName,
      'card_number': cardNumber,
      'card_expiration_month': cardExpirationMonth,
      'card_expiration_year': cardExpirationYear,
      'card_security_code': cardSecurityCode,
      'card_issuer': cardIssuer,
      'card_pin': cardPin,

      // API
      'api_key': apiKey,

      // OAuth
      'oauth_provider': oauthProvider,
      'oauth_client_id': oauthClientId,
      'oauth_access_token': oauthAccessToken,
      'oauth_refresh_token': oauthRefreshToken,

      // Wifi
      'wifi_ssid': wifiSsid,
      'wifi_password': wifiPassword,

      // PGP
      'pgp_private_key': pgpPrivateKey,
      'pgp_public_key': pgpPublicKey,
      'pgp_fingerprint': pgpFingerprint,

      // S-MIME
      'smime_certificate': smimeCertificate,
      'smime_private_key': smimePrivateKey,
    };
  }

  @override
  List<Object?> get props => [id];
}

extension PasswordEntryEncryptionExtions on VaultEntry {
  /// Encrypts all fields except id using the provided encrypt function.
  Future<VaultEntry> encrypt(Future<String> Function(String) encryptFunc) async {
    return VaultEntry._(
      id: id,
      type: await encryptFunc(type),
      name: await encryptFunc(name),
      createdAt: await encryptFunc(createdAt),
      updatedAt: await encryptFunc(updatedAt),
      username: await encryptFunc(username),
      password: await encryptFunc(password),
      urls: await Future.wait(urls.map(encryptFunc)),
      comments: await encryptFunc(comments),
      folder: await encryptFunc(folder),
      sshPrivateKey: await encryptFunc(sshPrivateKey),
      sshPublicKey: await encryptFunc(sshPublicKey),
      sshFingerprint: await encryptFunc(sshFingerprint),
      cardHolderName: await encryptFunc(cardHolderName),
      cardNumber: await encryptFunc(cardNumber),
      cardExpirationMonth: await encryptFunc(cardExpirationMonth),
      cardExpirationYear: await encryptFunc(cardExpirationYear),
      cardSecurityCode: await encryptFunc(cardSecurityCode),
      cardIssuer: await encryptFunc(cardIssuer),
      cardPin: await encryptFunc(cardPin),
      apiKey: await encryptFunc(apiKey),

      // OAuth
      oauthProvider: await encryptFunc(oauthProvider),
      oauthClientId: await encryptFunc(oauthClientId),
      oauthAccessToken: await encryptFunc(oauthAccessToken),
      oauthRefreshToken: await encryptFunc(oauthRefreshToken),

      // Wifi
      wifiSsid: await encryptFunc(wifiSsid),
      wifiPassword: await encryptFunc(wifiPassword),

      // PGP
      pgpPrivateKey: await encryptFunc(pgpPrivateKey),
      pgpPublicKey: await encryptFunc(pgpPublicKey),
      pgpFingerprint: await encryptFunc(pgpFingerprint),

      // S-MIME
      smimeCertificate: await encryptFunc(smimeCertificate),
      smimePrivateKey: await encryptFunc(smimePrivateKey),
    );
  }

  /// Decrypts all fields except id using the provided decrypt function.
  Future<VaultEntry> decrypt(Future<String> Function(String) decryptFunc) async {
    // Use a defensive helper: if a field is empty or decryption fails
    // (for example because the value was never encrypted), fall back
    // to the original value. This preserves compatibility when new
    // columns are added with empty or plaintext values.
    Future<String> safeDecrypt(String v) async {
      if (v.isEmpty) return '';
      try {
        return await decryptFunc(v);
      } catch (_) {
        // If decryption fails, assume the stored value is plaintext and
        // return it unchanged rather than throwing.
        return v;
      }
    }

    return VaultEntry._(
      id: id,
      type: await safeDecrypt(type),
      name: await safeDecrypt(name),
      createdAt: await safeDecrypt(createdAt),
      updatedAt: await safeDecrypt(updatedAt),
      comments: await safeDecrypt(comments),
      folder: await safeDecrypt(folder),

      // Credential
      username: await safeDecrypt(username),
      password: await safeDecrypt(password),
      urls: await Future.wait(urls.map(safeDecrypt)),

      // SSH
      sshPrivateKey: await safeDecrypt(sshPrivateKey),
      sshPublicKey: await safeDecrypt(sshPublicKey),
      sshFingerprint: await safeDecrypt(sshFingerprint),

      // Card
      cardHolderName: await safeDecrypt(cardHolderName),
      cardNumber: await safeDecrypt(cardNumber),
      cardExpirationMonth: await safeDecrypt(cardExpirationMonth),
      cardExpirationYear: await safeDecrypt(cardExpirationYear),
      cardSecurityCode: await safeDecrypt(cardSecurityCode),
      cardIssuer: await safeDecrypt(cardIssuer),
      cardPin: await safeDecrypt(cardPin),

      // API
      apiKey: await safeDecrypt(apiKey),

      // OAuth
      oauthProvider: await safeDecrypt(oauthProvider),
      oauthClientId: await safeDecrypt(oauthClientId),
      oauthAccessToken: await safeDecrypt(oauthAccessToken),
      oauthRefreshToken: await safeDecrypt(oauthRefreshToken),

      // Wifi
      wifiSsid: await safeDecrypt(wifiSsid),
      wifiPassword: await safeDecrypt(wifiPassword),

      // PGP
      pgpPrivateKey: await safeDecrypt(pgpPrivateKey),
      pgpPublicKey: await safeDecrypt(pgpPublicKey),
      pgpFingerprint: await safeDecrypt(pgpFingerprint),

      // S-MIME
      smimeCertificate: await safeDecrypt(smimeCertificate),
      smimePrivateKey: await safeDecrypt(smimePrivateKey),
    );
  }
}
