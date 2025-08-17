import 'package:open_password_manager/shared/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/application/services/crypto_service_impl.dart';
import 'package:open_password_manager/shared/application/services/file_picker_service.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/application/services/storage_service_impl.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';
import 'package:open_password_manager/shared/application/services/file_picker_service_impl.dart';

class ServiceFactory {
  StorageService getStorageService() {
    return StorageService(StorageServiceImpl());
  }

  FilePickerService getFilePickerService() {
    return FilePickerService(FilePickerServiceImpl());
  }

  CryptoService getCryptoService(
    CryptoUtilsRepository cryptoUtilsRepo,
    StorageService storageService,
  ) {
    return CryptoService(
      CryptoServiceImpl(cryptoUtilsRepo: cryptoUtilsRepo, storageService: storageService),
    );
  }
}
