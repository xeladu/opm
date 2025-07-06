import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';
import 'package:open_password_manager/features/password/domain/repositories/export_repository.dart';

class ExportRepositoryImpl implements ExportRepository {
  @override
  Future<void> exportPasswordEntries(List<PasswordEntry> entries) async {
    // Create CSV header
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
        entry.createdAt.toIso8601String(),
        entry.updatedAt.toIso8601String(),
        entry.username,
        entry.password,
        '"${entry.urls.join(';')}"',
        entry.comments.replaceAll('\n', ' '),
      ];
      csvBuffer.writeln(
        row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','),
      );
    }

    await _download(csvBuffer.toString(), 'export');
  }

  Future _download(String csv, String fileName) async {
    final blobParts = ([csv] as dynamic) as JSArray<BlobPart>;
    final blob = Blob(blobParts, BlobPropertyBag(type: 'text/csv'));
    final url = URL.createObjectURL(blob);

    final anchor = HTMLAnchorElement()
      ..href = url
      ..download = '$fileName.csv';

    document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    URL.revokeObjectURL(url);
  }
}
