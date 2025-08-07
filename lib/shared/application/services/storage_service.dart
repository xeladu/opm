import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_password_manager/shared/domain/entities/credentials.dart';

class StorageService {
  static AndroidOptions _getAndroidOptions() =>
      AndroidOptions(encryptedSharedPreferences: true);
  final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  final _credentialsStorageKey = "credentials";

  Future<void> storeAuthCredentials(Credentials credentials) async {
    await _storage.write(
      key: _credentialsStorageKey,
      value: jsonEncode(credentials.toJson()),
    );
  }

  Future<Credentials> loadAuthCredentials() async {
    final storageValue = await _storage.read(key: _credentialsStorageKey);

    return storageValue == null
        ? Credentials.empty()
        : Credentials.fromJson(jsonDecode(storageValue));
  }
}
