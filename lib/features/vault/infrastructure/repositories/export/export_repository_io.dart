import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<void> downloadFile(String content, String fileType, String fileName) async {
  await FilePicker.platform.saveFile(
    dialogTitle: 'Select location to save file',
    fileName: '$fileName.$fileType',
    type: FileType.custom,
    allowedExtensions: [fileType],
    bytes: Uint8List.fromList(utf8.encode(content)),
  );
}
