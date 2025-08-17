import 'package:file_picker/file_picker.dart';
import 'package:open_password_manager/shared/application/services/file_picker_service_impl.dart';

class FilePickerService {
  final FilePickerServiceImpl _picker;

  FilePickerService(this._picker);

  Future<FilePickerResult?> pickFile() async {
    return await _picker.pickFile();
  }
}
