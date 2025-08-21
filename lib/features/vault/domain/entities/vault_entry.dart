import 'package:equatable/equatable.dart';

class VaultEntry extends Equatable {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final String username;
  final String password;
  final List<String> urls;
  final String comments;
  final String folder;

  const VaultEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.password,
    required this.urls,
    required this.comments,
    required this.folder,
  });

  VaultEntry.empty()
    : this(
        id: '',
        name: '',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        username: '',
        password: '',
        urls: const [],
        comments: '',
        folder: '',
      );

  VaultEntry copyWith({
    String? id,
    String? name,
    String? createdAt,
    String? updatedAt,
    String? username,
    String? password,
    List<String>? urls,
    String? comments,
    String? folder,
  }) {
    return VaultEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      password: password ?? this.password,
      urls: urls ?? this.urls,
      comments: comments ?? this.comments,
      folder: folder ?? this.folder,
    );
  }

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json.containsKey('id') && json['id'] is String ? json['id'] : '',
      name: json.containsKey('name') && json['name'] is String ? json['name'] : '',
      createdAt: json.containsKey('created_at') && json['created_at'] is String
          ? json['created_at']
          : DateTime.now().toIso8601String(),
      updatedAt: json.containsKey('updated_at') && json['updated_at'] is String
          ? json['updated_at']
          : DateTime.now().toIso8601String(),
      username: json.containsKey('username') && json['username'] is String ? json['username'] : '',
      password: json.containsKey('password') && json['password'] is String ? json['password'] : '',
      urls: json.containsKey('urls') && json['urls'] is List
          ? List<String>.from(json['urls'].whereType<String>())
          : const [],
      comments: json.containsKey('comments') && json['comments'] is String ? json['comments'] : '',
      folder: json.containsKey('folder') && json['folder'] is String ? json['folder'] : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'username': username,
      'password': password,
      'urls': urls,
      'comments': comments,
      'folder': folder,
    };
  }

  @override
  List<Object?> get props => [id];
}

extension PasswordEntryEncryptionExtions on VaultEntry {
  /// Encrypts all fields except id using the provided encrypt function.
  Future<VaultEntry> encrypt(Future<String> Function(String) encryptFunc) async {
    return VaultEntry(
      id: id,
      name: await encryptFunc(name),
      createdAt: await encryptFunc(createdAt),
      updatedAt: await encryptFunc(updatedAt),
      username: await encryptFunc(username),
      password: await encryptFunc(password),
      urls: await Future.wait(urls.map(encryptFunc)),
      comments: await encryptFunc(comments),
      folder: await encryptFunc(folder),
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

    return VaultEntry(
      id: id,
      name: await safeDecrypt(name),
      createdAt: await safeDecrypt(createdAt),
      updatedAt: await safeDecrypt(updatedAt),
      username: await safeDecrypt(username),
      password: await safeDecrypt(password),
      urls: await Future.wait(urls.map(safeDecrypt)),
      comments: await safeDecrypt(comments),
      folder: await safeDecrypt(folder),
    );
  }
}
