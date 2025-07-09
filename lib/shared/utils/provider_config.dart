import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/utils/app_config.dart';
import 'package:open_password_manager/shared/utils/hosting_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderConfig {
  final AppConfig appConfig;
  final HostingProvider hostingProvider;
  final SupabaseClient? supabaseClient;
  final Client? appwriteClient;

  ProviderConfig({
    required this.appConfig,
    required this.hostingProvider,
    required this.supabaseClient,
    required this.appwriteClient,
  });
}
