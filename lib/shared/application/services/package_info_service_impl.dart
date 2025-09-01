import 'package:open_password_manager/shared/application/services/package_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoServiceImpl implements PackageInfoService {
  @override
  Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }
}
