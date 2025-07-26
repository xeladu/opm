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

  const VaultEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.password,
    required this.urls,
    required this.comments,
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
    );
  }

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json.containsKey('id') && json['id'] is String ? json['id'] : '',
      name: json.containsKey('name') && json['name'] is String
          ? json['name']
          : '',
      createdAt: json.containsKey('created_at') && json['created_at'] is String
          ? json['created_at']
          : DateTime.now().toIso8601String(),
      updatedAt: json.containsKey('updated_at') && json['updated_at'] is String
          ? json['updated_at']
          : DateTime.now().toIso8601String(),
      username: json.containsKey('username') && json['username'] is String
          ? json['username']
          : '',
      password: json.containsKey('password') && json['password'] is String
          ? json['password']
          : '',
      urls: json.containsKey('urls') && json['urls'] is List
          ? List<String>.from(json['urls'].whereType<String>())
          : const [],
      comments: json.containsKey('comments') && json['comments'] is String
          ? json['comments']
          : '',
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
    };
  }

  @override
  List<Object?> get props => [id];
}

extension PasswordEntryEncryptionExtions on VaultEntry {
  Future<VaultEntry> encrypt(
    Future<String> Function(String) encryptFunc,
  ) async {
    return VaultEntry(
      id: id,
      name: await encryptFunc(name),
      createdAt: await encryptFunc(createdAt),
      updatedAt: await encryptFunc(updatedAt),
      username: await encryptFunc(username),
      password: await encryptFunc(password),
      urls: await Future.wait(urls.map(encryptFunc)),
      comments: await encryptFunc(comments),
    );
  }

  /// Decrypts all fields except id using the provided decrypt function.
  Future<VaultEntry> decrypt(
    Future<String> Function(String) decryptFunc,
  ) async {
    return VaultEntry(
      id: id,
      name: await decryptFunc(name),
      createdAt: await decryptFunc(createdAt),
      updatedAt: await decryptFunc(updatedAt),
      username: await decryptFunc(username),
      password: await decryptFunc(password),
      urls: await Future.wait(urls.map(decryptFunc)),
      comments: await decryptFunc(comments),
    );
  }
}
