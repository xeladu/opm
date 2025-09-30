import 'dart:convert';

import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/exceptions/import_exception.dart';
import 'package:open_password_manager/features/vault/domain/repositories/import_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/utils/csv_helper.dart';

class ImportRepositoryImpl extends ImportRepository {
  static ImportRepositoryImpl? _instance;
  static ImportRepositoryImpl get instance {
    _instance ??= ImportRepositoryImpl._();

    return _instance!;
  }

  ImportRepositoryImpl._();

  /// Imports a 1Password CSV export file.
  ///
  /// Maps 1Password CSV fields to VaultEntry fields:
  ///
  /// | CSV Field           | VaultEntry Field |
  /// |---------------------|------------------|
  /// | Title               | name             |
  /// | Website             | urls (as list)   |
  /// | Username            | username         |
  /// | Password            | password         |
  /// | Notes               | comments         |
  /// | One-time password   | (ignored)        |
  /// | Favorite status     | (ignored)        |
  /// | Archived status     | (ignored)        |
  /// | Tags                | (ignored)        |
  /// | Security questions  | (ignored)        |
  /// | Linked apps         | (ignored)        |
  /// | Linked items        | (ignored)        |
  /// | Custom fields       | (ignored)        |
  ///
  /// All other fields are ignored. createdAt/updatedAt are set to now. id is generated.
  @override
  Future<List<VaultEntry>> importFrom1Password(String csvContent) async {
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) return [];

    final header = rows.first;
    final entries = <VaultEntry>[];

    for (final row in rows.skip(1)) {
      if (row.length != header.length) continue;

      final map = CsvHelper.mapCsvRowToHeader(header, row);
      entries.add(
        VaultEntry.empty().copyWith(
          id: Uuid().v4(),
          name: map['Title'] ?? '',
          username: map['Username'] ?? '',
          password: map['Password'] ?? '',
          urls: map['Website'] != null && map['Website']!.isNotEmpty ? [map['Website']!] : [],
          comments: map['Notes'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          folder: '',
        ),
      );
    }

    return entries;
  }

  // CSV parsing is now handled by csv_helper.dart

  /// Imports a Bitwarden CSV export file.
  ///
  /// Maps Bitwarden CSV fields to VaultEntry fields:
  ///
  /// | CSV Field        | VaultEntry Field |
  /// |------------------|------------------|
  /// | name             | name             |
  /// | login_username   | username         |
  /// | login_password   | password         |
  /// | login_uri        | urls (as list)   |
  /// | notes            | comments         |
  /// | folder           | folder           |
  /// | favorite         | (ignored)        |
  /// | type             | (ignored)        |
  /// | fields           | (ignored)        |
  /// | reprompt         | (ignored)        |
  /// | login_totp       | (ignored)        |
  ///
  /// All other fields are ignored. createdAt/updatedAt are set to now. id is generated.
  @override
  Future<List<VaultEntry>> importFromBitwarden(String csvContent) async {
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) return [];

    final header = rows.first;
    final entries = <VaultEntry>[];

    for (final row in rows.skip(1)) {
      if (row.length != header.length) continue;

      final map = CsvHelper.mapCsvRowToHeader(header, row);
      entries.add(
        VaultEntry.empty().copyWith(
          id: Uuid().v4(),
          name: map['name'] ?? '',
          username: map['login_username'] ?? '',
          password: map['login_password'] ?? '',
          urls: map['login_uri'] != null && map['login_uri']!.isNotEmpty ? [map['login_uri']!] : [],
          comments: map['notes'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          folder: map['folder'] ?? '',
        ),
      );
    }

    return entries;
  }

  /// Imports a KeePass CSV export file.
  ///
  /// Maps KeePass CSV fields to VaultEntry fields:
  ///
  /// | CSV Field   | VaultEntry Field |
  /// |-------------|------------------|
  /// | Account     | name             |
  /// | Login Name  | username         |
  /// | Password    | password         |
  /// | Web Site    | urls (as list)   |
  /// | Comments    | comments         |
  ///
  /// All other fields are ignored. createdAt/updatedAt are set to now. id is generated.
  @override
  Future<List<VaultEntry>> importFromKeepass(String csvContent) async {
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) return [];

    final header = rows.first;
    final entries = <VaultEntry>[];

    for (final row in rows.skip(1)) {
      if (row.length != header.length) continue;

      final map = CsvHelper.mapCsvRowToHeader(header, row);
      entries.add(
        VaultEntry.empty().copyWith(
          id: Uuid().v4(),
          name: map['Account'] ?? '',
          username: map['Login Name'] ?? '',
          password: map['Password'] ?? '',
          urls: map['Web Site'] != null && map['Web Site']!.isNotEmpty ? [map['Web Site']!] : [],
          comments: map['Comments'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          folder: '',
        ),
      );
    }

    return entries;
  }

  /// Imports a Keeper CSV export file.
  ///
  /// Maps Keeper CSV fields to VaultEntry fields:
  ///
  /// | CSV Field        | VaultEntry Field |
  /// |------------------|------------------|
  /// | Title            | name             |
  /// | Login            | username         |
  /// | Password         | password         |
  /// | Website Address  | urls (as list)   |
  /// | Notes            | comments         |
  /// | Folder           | folder           |
  /// | Shared Folder    | (ignored)        |
  /// | Custom Fields    | (ignored)        |
  ///
  /// All other fields are ignored. createdAt/updatedAt are set to now. id is generated.
  @override
  Future<List<VaultEntry>> importFromKeeper(String csvContent) async {
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) return [];

    final header = rows.first;
    final entries = <VaultEntry>[];

    for (final row in rows.skip(1)) {
      if (row.length != header.length) continue;

      final map = CsvHelper.mapCsvRowToHeader(header, row);
      entries.add(
        VaultEntry.empty().copyWith(
          id: Uuid().v4(),
          name: map['Title'] ?? '',
          username: map['Login'] ?? '',
          password: map['Password'] ?? '',
          urls: map['Website Address'] != null && map['Website Address']!.isNotEmpty
              ? [map['Website Address']!]
              : [],
          comments: map['Notes'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          folder: map['Group'] ?? '',
        ),
      );
    }

    return entries;
  }

  /// Imports a LastPass CSV export file.
  ///
  /// Maps LastPass CSV fields to VaultEntry fields:
  ///
  /// | CSV Field | VaultEntry Field |
  /// |-----------|------------------|
  /// | name      | name             |
  /// | username  | username         |
  /// | password  | password         |
  /// | url       | urls (as list)   |
  /// | extra     | comments         |
  /// | grouping  | folder           |
  /// | fav       | (ignored)        |
  ///
  /// All other fields are ignored. createdAt/updatedAt are set to now. id is generated.
  @override
  Future<List<VaultEntry>> importFromLastPass(String csvContent) async {
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) return [];

    final header = rows.first;
    final entries = <VaultEntry>[];

    for (final row in rows.skip(1)) {
      if (row.length != header.length) continue;

      final map = CsvHelper.mapCsvRowToHeader(header, row);
      entries.add(
        VaultEntry.empty().copyWith(
          id: Uuid().v4(),
          name: map['name'] ?? '',
          username: map['username'] ?? '',
          password: map['password'] ?? '',
          urls: map['url'] != null && map['url']!.isNotEmpty ? [map['url']!] : [],
          comments: map['extra'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          folder: map['grouping'] ?? '',
        ),
      );
    }

    return entries;
  }

  /// Imports a OPM CSV export file.
  ///
  /// Maps OPM CSV fields to VaultEntry fields:
  ///
  /// | CSV Field      | VaultEntry Field |
  /// |----------------|------------------|
  /// | id             | (ignored)        |
  /// | name           | name             |
  /// | username       | username         |
  /// | password       | password         |
  /// | urls (as list) | urls (as list)   |
  /// | comments       | comments         |
  /// | createdAt      | createdAt        |
  /// | updatedAt      | updatedAt        |
  /// | folder         | folder           |
  @override
  Future<List<VaultEntry>> importFromOpm(String csvContent) async {
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) return [];

    final header = rows.first;
    final entries = <VaultEntry>[];

    for (final row in rows.skip(1)) {
      if (row.length != header.length) continue;

      final map = CsvHelper.mapCsvRowToHeader(header, row);
      entries.add(
        VaultEntry.empty().copyWith(
          id: Uuid().v4(),
          name: map['name'] ?? '',
          username: map['user'] ?? '',
          password: map['password'] ?? '',
          urls: map['urls'] != null && map['urls']!.isNotEmpty
              ? map['urls']!.split(";").map((e) => e.toString()).toList()
              : [],
          comments: map['comments'] ?? '',
          createdAt: map['createdAt'] != null
              ? DateTime.parse(map['createdAt']!).toIso8601String()
              : DateTime.now().toIso8601String(),
          updatedAt: map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt']!).toIso8601String()
              : DateTime.now().toIso8601String(),
          folder: map['folder'] ?? '',
        ),
      );
    }

    return entries;
  }

  @override
  Future<List<VaultEntry>> importOpmBackup(String jsonContent) async {
    final decoded = jsonDecode(jsonContent) as Map<String, dynamic>;
    final entries = decoded['entries'] as List<dynamic>;

    final result = <VaultEntry>[];

    for(final entry in entries){
      result.add(VaultEntry.fromJson(entry));
    }

    return result;
  }

  @override
  void validate1PasswordFile(String csvContent) {
    if (csvContent.isEmpty) {
      throw ImportException("No content");
    }
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) {
      throw ImportException("No data");
    }

    final header = rows.first;
    final hasNameHeader = header.contains("Title");
    final hasEmailHeader = header.contains("Username");
    final hasPasswordHeader = header.contains("Password");
    final hasUrlHeader = header.contains("Website");
    final hasCommentsHeader = header.contains("Notes");

    if (!hasNameHeader ||
        !hasEmailHeader ||
        !hasPasswordHeader ||
        !hasUrlHeader ||
        !hasCommentsHeader) {
      var errorString = "The following expected header fields are missing:\n";
      errorString += hasNameHeader ? "" : "Title, ";
      errorString += hasEmailHeader ? "" : "Username, ";
      errorString += hasPasswordHeader ? "" : "Password, ";
      errorString += hasUrlHeader ? "" : "Website, ";
      errorString += hasCommentsHeader ? "" : "Notes, ";
      errorString = errorString.substring(0, errorString.length - 2);

      throw ImportException(errorString);
    }
  }

  @override
  void validateBitwardenFile(String csvContent) {
    if (csvContent.isEmpty) {
      throw ImportException("No content");
    }
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) {
      throw ImportException("No data");
    }

    final header = rows.first;
    final hasNameHeader = header.contains("name");
    final hasEmailHeader = header.contains("login_username");
    final hasPasswordHeader = header.contains("login_password");
    final hasUrlHeader = header.contains("login_uri");
    final hasCommentsHeader = header.contains("notes");

    if (!hasNameHeader ||
        !hasEmailHeader ||
        !hasPasswordHeader ||
        !hasUrlHeader ||
        !hasCommentsHeader) {
      var errorString = "The following expected header fields are missing:\n";
      errorString += hasNameHeader ? "" : "name, ";
      errorString += hasEmailHeader ? "" : "login_username, ";
      errorString += hasPasswordHeader ? "" : "login_password, ";
      errorString += hasUrlHeader ? "" : "login_uri ,";
      errorString += hasCommentsHeader ? "" : "notes, ";
      errorString = errorString.substring(0, errorString.length - 2);

      throw ImportException(errorString);
    }
  }

  @override
  void validateKeepassFile(String csvContent) {
    if (csvContent.isEmpty) {
      throw ImportException("No content");
    }
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) {
      throw ImportException("No data");
    }

    final header = rows.first;
    final hasNameHeader = header.contains("Account");
    final hasEmailHeader = header.contains("Login Name");
    final hasPasswordHeader = header.contains("Password");
    final hasUrlHeader = header.contains("Web Site");
    final hasCommentsHeader = header.contains("Comments");

    if (!hasNameHeader ||
        !hasEmailHeader ||
        !hasPasswordHeader ||
        !hasUrlHeader ||
        !hasCommentsHeader) {
      var errorString = "The following expected header fields are missing:";
      errorString += hasNameHeader ? "" : "Account, ";
      errorString += hasEmailHeader ? "" : "Login Name, ";
      errorString += hasPasswordHeader ? "" : "Password, ";
      errorString += hasUrlHeader ? "" : "Web Site, ";
      errorString += hasCommentsHeader ? "" : "Comments, ";
      errorString = errorString.substring(0, errorString.length - 2);

      throw ImportException(errorString);
    }
  }

  @override
  void validateKeeperFile(String csvContent) {
    if (csvContent.isEmpty) {
      throw ImportException("No content");
    }
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) {
      throw ImportException("No data");
    }

    final header = rows.first;
    final hasNameHeader = header.contains("Title");
    final hasEmailHeader = header.contains("Login");
    final hasPasswordHeader = header.contains("Password");
    final hasUrlHeader = header.contains("Website Address");
    final hasCommentsHeader = header.contains("Notes");

    if (!hasNameHeader ||
        !hasEmailHeader ||
        !hasPasswordHeader ||
        !hasUrlHeader ||
        !hasCommentsHeader) {
      var errorString = "The following expected header fields are missing:\n";
      errorString += hasNameHeader ? "" : "Title, ";
      errorString += hasEmailHeader ? "" : "Login, ";
      errorString += hasPasswordHeader ? "" : "Password, ";
      errorString += hasUrlHeader ? "" : "Website Address, ";
      errorString += hasCommentsHeader ? "" : "Notes, ";
      errorString = errorString.substring(0, errorString.length - 2);

      throw ImportException(errorString);
    }
  }

  @override
  void validateLastPassFile(String csvContent) {
    if (csvContent.isEmpty) {
      throw ImportException("No content");
    }
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) {
      throw ImportException("No data");
    }

    final header = rows.first;
    final hasNameHeader = header.contains("name");
    final hasEmailHeader = header.contains("username");
    final hasPasswordHeader = header.contains("password");
    final hasUrlHeader = header.contains("url");
    final hasCommentsHeader = header.contains("extra");

    if (!hasNameHeader ||
        !hasEmailHeader ||
        !hasPasswordHeader ||
        !hasUrlHeader ||
        !hasCommentsHeader) {
      var errorString = "The following expected header fields are missing:\n";
      errorString += hasNameHeader ? "" : "name, ";
      errorString += hasEmailHeader ? "" : "username, ";
      errorString += hasPasswordHeader ? "" : "password, ";
      errorString += hasUrlHeader ? "" : "url, ";
      errorString += hasCommentsHeader ? "" : "extra, ";
      errorString = errorString.substring(0, errorString.length - 2);

      throw ImportException(errorString);
    }
  }

  @override
  void validateOpmFile(String csvContent) {
    if (csvContent.isEmpty) {
      throw ImportException("No content");
    }
    final rows = CsvHelper.parseCsv(csvContent);

    if (rows.length < 2) {
      throw ImportException("No data");
    }

    final header = rows.first;
    final hasNameHeader = header.contains("name");
    final hasEmailHeader = header.contains("user");
    final hasPasswordHeader = header.contains("password");
    final hasUrlHeader = header.contains("urls");
    final hasCommentsHeader = header.contains("comments");
    final hasCreatedAtHeader = header.contains("createdAt");
    final hasUpdatedAtHeader = header.contains("updatedAt");

    if (!hasNameHeader ||
        !hasEmailHeader ||
        !hasPasswordHeader ||
        !hasUrlHeader ||
        !hasCommentsHeader ||
        !hasCreatedAtHeader ||
        !hasUpdatedAtHeader) {
      var errorString = "The following expected header fields are missing:\n";
      errorString += hasNameHeader ? "" : "name, ";
      errorString += hasEmailHeader ? "" : "user, ";
      errorString += hasPasswordHeader ? "" : "password, ";
      errorString += hasUrlHeader ? "" : "urls, ";
      errorString += hasCommentsHeader ? "" : "comments, ";
      errorString += hasCreatedAtHeader ? "" : "createdAt, ";
      errorString += hasUpdatedAtHeader ? "" : "updatedAt, ";
      errorString = errorString.substring(0, errorString.length - 2);

      throw ImportException(errorString);
    }
  }

  @override
  void validateOpmBackup(String jsonContent) {
    if (jsonContent.isEmpty) {
      throw ImportException("No content");
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonContent);
    } catch (e) {
      throw ImportException("Invalid JSON");
    }

    if (decoded is! Map) {
      throw ImportException("Invalid backup format");
    }

    // Top-level required fields
    final requiredTop = ['version', 'exportedAt', 'entryCount', 'entries'];
    final missingTop = requiredTop.where((k) => !decoded.containsKey(k)).toList();

    if (missingTop.isNotEmpty) {
      var errorString = "The following expected top-level fields are missing:\n";
      for (final m in missingTop) {
        errorString += "$m, ";
      }
      errorString = errorString.substring(0, errorString.length - 2);
      throw ImportException(errorString);
    }

    final entries = decoded['entries'];
    if (entries is! List) {
      throw ImportException("Invalid entries array");
    }

    final entryCount = decoded["entryCount"] as int;
    if (entries.length != entryCount) {
      throw ImportException("'entryCount' is $entryCount, but found ${entries.length} entries!");
    }

    // Required fields per entry
    final requiredEntryFields = [
      'id',
      'type',
      'name',
      'created_at',
      'updated_at',
      'comments',
      'folder',
      'username',
      'password',
      'urls',
      'ssh_private_key',
      'ssh_public_key',
      'ssh_fingerprint',
      'card_holder_name',
      'card_number',
      'card_expiration_month',
      'card_expiration_year',
      'card_security_code',
      'card_issuer',
      'card_pin',
      'api_key',
      'oauth_provider',
      'oauth_client_id',
      'oauth_access_token',
      'oauth_refresh_token',
      'wifi_ssid',
      'wifi_password',
      'pgp_private_key',
      'pgp_public_key',
      'pgp_fingerprint',
      'smime_certificate',
      'smime_private_key',
    ];

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry is! Map) {
        throw ImportException('Entry at index $i is not an object');
      }

      final missing = requiredEntryFields.where((f) => !entry.containsKey(f)).toList();
      if (missing.isNotEmpty) {
        var errorString = 'Entry at index $i is missing the following fields:\n';
        for (final m in missing) {
          errorString += '$m, ';
        }
        errorString = errorString.substring(0, errorString.length - 2);
        throw ImportException(errorString);
      }

      // urls should be a list (array) in JSON
      if (entry['urls'] is! List) {
        throw ImportException('Entry at index $i has invalid urls field (expected array)');
      }
    }
  }
}
