import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<FilePickerResult?> pickFile() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["csv"],
      withData: true,
    );
  }
}
