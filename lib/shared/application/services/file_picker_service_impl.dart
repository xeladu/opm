import 'package:file_picker/file_picker.dart';
import 'package:open_password_manager/shared/application/services/file_picker_service.dart';

class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<FilePickerResult?> pickFile({List<String>? allowedExtensions}) async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? ["csv"],
      withData: true,
    );
  }
}
