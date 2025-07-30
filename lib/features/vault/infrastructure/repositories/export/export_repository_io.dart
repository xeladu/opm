import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(
  String content,
  String fileType,
  String fileName,
) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName.$fileType');
  await file.writeAsString(content);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}
