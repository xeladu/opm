import 'dart:js_interop';
import 'package:web/web.dart';

Future<void> downloadFile(String csv, String fileName) async {
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
