import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';

import 'export_repository_web.dart'
    if (dart.library.io) 'export_repository_io.dart';

class ExportRepositoryImpl implements ExportRepository {
  static ExportRepositoryImpl? _instance;
  static ExportRepositoryImpl get instance {
    _instance ??= ExportRepositoryImpl._();

    return _instance!;
  }

  ExportRepositoryImpl._();

  @override
  Future<void> exportPasswordEntries(List<VaultEntry> entries) async {
    final headers = [
      'id',
      'name',
      'createdAt',
      'updatedAt',
      'user',
      'password',
      'urls',
      'comments',
    ];
    final csvBuffer = StringBuffer();
    csvBuffer.writeln(headers.join(','));

    for (final entry in entries) {
      final row = [
        entry.id,
        entry.name,
        entry.createdAt,
        entry.updatedAt,
        entry.username,
        entry.password,
        entry.urls.join(';').replaceAll('\n', ''),
        entry.comments.replaceAll('\n', ' '),
      ];
      csvBuffer.writeln(
        row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','),
      );
    }

    await _download(csvBuffer.toString(), 'export');
  }

  Future<void> _download(String csv, String fileName) async {
    await downloadFile(csv, fileName);
  }
}
