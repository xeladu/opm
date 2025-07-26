import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/appwrite_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/firebase_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/supabase_auth_repository_impl.dart';
import 'package:open_password_manager/features/password/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/password/domain/repositories/password_repository.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/appwrite/appwrite_password_repository_impl.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/export_repository_impl.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/firebase/firebase_password_repository_impl.dart';
import 'package:open_password_manager/features/password/infrastructure/repositories/supabase/supabase_password_repository_impl.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/clipboard_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/cryptography_repository_impl.dart';
import 'package:open_password_manager/shared/utils/hosting_provider.dart';
import 'package:open_password_manager/shared/utils/provider_config.dart';

class ProviderFactory {
  static AuthRepository getAuthProvider(ProviderConfig config) {
    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return FirebaseAuthRepositoryImpl();
      case HostingProvider.supabase:
        return SupabaseAuthRepositoryImpl();
      case HostingProvider.appwrite:
        if (config.appwriteClient == null) {
          throw Exception("Invalid appwrite client configuration");
        }

        return AppwriteAuthRepositoryImpl(config.appwriteClient!);
    }
  }

  static ExportRepository getExportProvider() {
    return ExportRepositoryImpl.instance;
  }

  static CryptographyRepository getCryptoProvider() {
    return CryptographyRepositoryImpl.instance;
  }

  static PasswordRepository getPasswordProvider(ProviderConfig config) {
    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return FirebasePasswordRepositoryImpl(
          config: config.appConfig.firebaseConfig!,
          cryptoRepo: getCryptoProvider(),
        );
      case HostingProvider.supabase:
        if (config.supabaseClient == null) {
          throw Exception("Invalid supabase client configuration");
        }

        return SupabasePasswordRepositoryImpl(
          client: config.supabaseClient!,
          databaseName: config.appConfig.supabaseConfig!.databaseName,
          cryptoRepo: getCryptoProvider(),
        );
      case HostingProvider.appwrite:
        if (config.appwriteClient == null) {
          throw Exception("Invalid appwrite client configuration");
        }

        return AppwritePasswordRepositoryImpl(
          client: config.appwriteClient!,
          config: config.appConfig.appwriteConfig!,
          cryptoRepo: getCryptoProvider(),
        );
    }
  }

  static ClipboardRepository getClipboardProvider() {
    return ClipboardRepositoryImpl.instance;
  }
}
