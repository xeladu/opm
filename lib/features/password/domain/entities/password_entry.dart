class PasswordEntry {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String user;
  final String password;
  final List<String> urls;
  final String comments;

  const PasswordEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.password,
    required this.urls,
    required this.comments,
  });

  PasswordEntry.empty()
    : id = '',
      name = '',
      createdAt = DateTime.now(),
      updatedAt = DateTime.now(),
      user = '',
      password = '',
      urls = const [],
      comments = '';

  PasswordEntry copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? user,
    String? password,
    List<String>? urls,
    String? comments,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
      user: user ?? this.user,
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
      createdAt: json.containsKey('createdAt') && json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json.containsKey('updatedAt') && json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      user: json.containsKey('user') && json['user'] is String
          ? json['user']
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user,
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
          user == other.user &&
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
      user.hashCode ^
      password.hashCode ^
      Object.hashAll(urls) ^
      comments.hashCode;
}
