import 'package:equatable/equatable.dart';

class CryptoUtils extends Equatable {
  /// Shared salt to generate secure encryptions
  final String salt;

  /// Shared encrypted master encryption key to encrypt/decrypt all data
  final String encryptedMasterKey;

  const CryptoUtils({required this.salt, required this.encryptedMasterKey});

  const CryptoUtils.empty() : this(encryptedMasterKey: "", salt: "");

  factory CryptoUtils.fromJson(Map<String, dynamic> json) {
    return CryptoUtils(salt: json['salt'] as String, encryptedMasterKey: json['encMek'] as String);
  }

  CryptoUtils copyWith({String? newSalt, String? encMek}) {
    return CryptoUtils(salt: newSalt ?? salt, encryptedMasterKey: encMek ?? encryptedMasterKey);
  }

  Map<String, dynamic> toJson() {
    return {'salt': salt, 'encMek': encryptedMasterKey};
  }

  @override
  List<Object?> get props => [salt, encryptedMasterKey];
}
