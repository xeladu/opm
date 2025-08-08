import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/utils/file_picker_service.dart';

class ServiceFactory {
  StorageService getStorageService() {
    return StorageService();
  }

  FilePickerService getFilePickerService() {
    return FilePickerService();
  }
}
