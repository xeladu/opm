class PasswordEntry {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final String username;
  final String password;
  final List<String> urls;
  final String comments;

  const PasswordEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.password,
    required this.urls,
    required this.comments,
  });

  PasswordEntry.empty()
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

  PasswordEntry copyWith({
    String? id,
    String? name,
    String? createdAt,
    String? updatedAt,
    String? username,
    String? password,
    List<String>? urls,
    String? comments,
  }) {
    return PasswordEntry(
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

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          username == other.username &&
          password == other.password &&
          urls.length == other.urls.length &&
          urls.every((u) => other.urls.contains(u)) &&
          comments == other.comments;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      username.hashCode ^
      password.hashCode ^
      Object.hashAll(urls) ^
      comments.hashCode;
}

extension PasswordEntryEncryptionExtions on PasswordEntry {
  Future<PasswordEntry> encrypt(
    Future<String> Function(String) encryptFunc,
  ) async {
    return PasswordEntry(
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
  Future<PasswordEntry> decrypt(
    Future<String> Function(String) decryptFunc,
  ) async {
    return PasswordEntry(
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
