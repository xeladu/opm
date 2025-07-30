import 'dart:js_interop';
import 'package:web/web.dart';

Future<void> downloadFile(
  String content,
  String fileType,
  String fileName,
) async {
  final blobParts = ([content] as dynamic) as JSArray<BlobPart>;
  final blob = Blob(blobParts, BlobPropertyBag(type: 'text/$fileType'));
  final url = URL.createObjectURL(blob);

  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = '$fileName.$fileType';

  document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  URL.revokeObjectURL(url);
}
