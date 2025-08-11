import 'package:open_password_manager/shared/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';
import 'package:open_password_manager/shared/utils/file_picker_service.dart';

class ServiceFactory {
  StorageService getStorageService() {
    return StorageService();
  }

  FilePickerService getFilePickerService() {
    return FilePickerService();
  }

  CryptoService getCryptoService(
    CryptoUtilsRepository cryptoUtilsRepo,
    StorageService storageService,
  ) {
    return CryptoService(cryptoUtilsRepo: cryptoUtilsRepo, storageService: storageService);
  }
}
