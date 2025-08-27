import 'package:file_picker/file_picker.dart';

class FilePickerServiceImpl {
  Future<FilePickerResult?> pickFile({List<String>? allowedExtensions}) async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? ["csv"],
      withData: true,
    );
  }
}
