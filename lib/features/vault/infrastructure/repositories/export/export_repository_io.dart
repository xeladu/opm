import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(String csv, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName.csv');
  await file.writeAsString(csv);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}
