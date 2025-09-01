import 'package:file_picker/file_picker.dart';

abstract class FilePickerService {
  Future<FilePickerResult?> pickFile({List<String>? allowedExtensions});
}
