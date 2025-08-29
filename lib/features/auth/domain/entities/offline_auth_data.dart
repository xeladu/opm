import 'package:equatable/equatable.dart';

class OfflineAuthData extends Equatable {
  final String salt;
  final String email;
  final Map<String, dynamic>? kdf;

  const OfflineAuthData({required this.salt, required this.email, this.kdf});

  const OfflineAuthData.empty() : this(salt: "", email: "", kdf: null);

  factory OfflineAuthData.fromJson(Map<String, dynamic> json) {
    return OfflineAuthData(
      salt: json['salt'] as String? ?? '',
      email: json['email'] as String? ?? '',
      kdf: json['kdf'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'salt': salt, 'email': email, 'kdf': kdf};
  }

  @override
  List<Object?> get props => [salt, email];
}
