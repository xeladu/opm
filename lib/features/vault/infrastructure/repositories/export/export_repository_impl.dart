import 'dart:convert';

import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';

import 'export_repository_web.dart' if (dart.library.io) 'export_repository_io.dart';

class ExportRepositoryImpl implements ExportRepository {
  static ExportRepositoryImpl? _instance;
  static ExportRepositoryImpl get instance {
    _instance ??= ExportRepositoryImpl._();

    return _instance!;
  }

  ExportRepositoryImpl._();

  @override
  Future<void> exportPasswordEntriesCsv(List<VaultEntry> entries) async {
    final headers = [
      'id',
      'name',
      'createdAt',
      'updatedAt',
      'user',
      'password',
      'urls',
      'comments',
      'folder',
    ];
    final csvBuffer = StringBuffer();
    csvBuffer.writeln(headers.join(','));

    for (final entry in entries.where((e) => e.type == VaultEntryType.credential.name)) {
      final row = [
        entry.id,
        entry.name,
        entry.createdAt,
        entry.updatedAt,
        entry.username,
        entry.password,
        entry.urls.join(';').replaceAll('\n', ''),
        entry.comments.replaceAll('\n', ' '),
        entry.folder,
      ];
      csvBuffer.writeln(row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','));
    }

    await _download(csvBuffer.toString(), 'csv', 'export');
  }

  @override
  Future<void> exportPasswordEntriesJson(List<VaultEntry> entries) async {
    final jsonEntries = entries.map((entry) => entry.toJson()).toList();

    final jsonData = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'entryCount': entries.length,
      'entries': jsonEntries,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    await _download(jsonString, 'json', 'export');
  }

  Future<void> _download(String content, String fileType, String fileName) async {
    await downloadFile(content, fileType, fileName);
  }
}
