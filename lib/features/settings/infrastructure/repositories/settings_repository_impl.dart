import 'package:open_password_manager/features/settings/domain/entities/settings.dart';
import 'package:open_password_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final StorageService storage;

  SettingsRepositoryImpl({required this.storage});

  @override
  Future<Settings> load() async {
    return await storage.loadAppSettings();
  }

  @override
  Future<void> save(Settings settings) async {
    await storage.storeAppSettings(settings);
  }
}
