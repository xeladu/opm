import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/repositories/import_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/utils/csv_helper.dart';

class ImportRepositoryImpl extends ImportRepository {
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
        VaultEntry(
          id: Uuid().v4(),
          name: map['Title'] ?? '',
          username: map['Username'] ?? '',
          password: map['Password'] ?? '',
          urls: map['Website'] != null && map['Website']!.isNotEmpty ? [map['Website']!] : [],
          comments: map['Notes'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
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
  /// | folder           | (ignored)        |
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
        VaultEntry(
          id: Uuid().v4(),
          name: map['name'] ?? '',
          username: map['login_username'] ?? '',
          password: map['login_password'] ?? '',
          urls: map['login_uri'] != null && map['login_uri']!.isNotEmpty ? [map['login_uri']!] : [],
          comments: map['notes'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
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
        VaultEntry(
          id: Uuid().v4(),
          name: map['Account'] ?? '',
          username: map['Login Name'] ?? '',
          password: map['Password'] ?? '',
          urls: map['Web Site'] != null && map['Web Site']!.isNotEmpty ? [map['Web Site']!] : [],
          comments: map['Comments'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
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
  /// | Folder           | (ignored)        |
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
        VaultEntry(
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
  /// | grouping  | (ignored)        |
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
        VaultEntry(
          id: Uuid().v4(),
          name: map['name'] ?? '',
          username: map['username'] ?? '',
          password: map['password'] ?? '',
          urls: map['url'] != null && map['url']!.isNotEmpty ? [map['url']!] : [],
          comments: map['extra'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    return entries;
  }
}
