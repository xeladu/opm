import 'package:open_password_manager/features/settings/domain/entities/settings.dart';

abstract class SettingsRepository {
  Future<void> save(Settings settings);
  Future<Settings> load();
}
