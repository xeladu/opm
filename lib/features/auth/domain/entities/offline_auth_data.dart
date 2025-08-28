import 'package:equatable/equatable.dart';

class OfflineAuthData extends Equatable {
  final String salt;
  final String derivedKey;
  final String email;

  const OfflineAuthData({required this.salt, required this.derivedKey, required this.email});

  const OfflineAuthData.empty() : this(derivedKey: "", salt: "", email: "");

  factory OfflineAuthData.fromJson(Map<String, dynamic> json) {
    return OfflineAuthData(
      salt: json['salt'] as String? ?? '',
      derivedKey: json['derivedKey'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'salt': salt, 'derivedKey': derivedKey, 'email': email};
  }

  @override
  List<Object?> get props => [salt, derivedKey, email];
}
