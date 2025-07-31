import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/appwrite_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/firebase_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/supabase_auth_repository_impl.dart';
import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/entry_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/appwrite_entry_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/export/export_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/firebase_entry_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/password_generator_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/supabase_entry_repository_impl.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/salt/appwrite_salt_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/clipboard_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/cryptography_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/salt/firebase_salt_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/salt/supabase_salt_repository_impl.dart';
import 'package:open_password_manager/shared/utils/hosting_provider.dart';
import 'package:open_password_manager/shared/domain/entities/provider_config.dart';

class ProviderFactory {
  static AuthRepository getAuthProvider(ProviderConfig config) {
    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return FirebaseAuthRepositoryImpl();
      case HostingProvider.supabase:
        if (config.supabaseClient == null) {
          throw Exception("Invalid supabase client configuration");
        }

        return SupabaseAuthRepositoryImpl(config.supabaseClient!);
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

  static PasswordGeneratorRepository getPasswordGeneratorProvider() {
    return PasswordGeneratorRepositoryImpl.instance;
  }

  static EntryRepository getPasswordProvider(ProviderConfig config) {
    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return FirebaseEntryRepositoryImpl(
          config: config.appConfig.firebaseConfig!,
          cryptoRepo: getCryptoProvider(),
        );
      case HostingProvider.supabase:
        if (config.supabaseClient == null) {
          throw Exception("Invalid supabase client configuration");
        }

        return SupabaseEntryRepositoryImpl(
          client: config.supabaseClient!,
          tableName: config.appConfig.supabaseConfig!.passwordDbName,
          cryptoRepo: getCryptoProvider(),
        );
      case HostingProvider.appwrite:
        if (config.appwriteClient == null) {
          throw Exception("Invalid appwrite client configuration");
        }

        return AppwriteEntryRepositoryImpl(
          client: config.appwriteClient!,
          config: config.appConfig.appwriteConfig!,
          cryptoRepo: getCryptoProvider(),
        );
    }
  }

  static ClipboardRepository getClipboardProvider() {
    return ClipboardRepositoryImpl.instance;
  }

  static SaltRepository getSaltProvider(ProviderConfig config) {
    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return const FirebaseSaltRepositoryImpl();
      case HostingProvider.supabase:
        if (config.supabaseClient == null) {
          throw Exception("Invalid supabase client configuration");
        }
        return SupabaseSaltRepositoryImpl(
          client: config.supabaseClient!,
          tableName: config.appConfig.supabaseConfig!.saltDbName,
        );
      case HostingProvider.appwrite:
        if (config.appwriteClient == null) {
          throw Exception("Invalid appwrite client configuration");
        }
        return AppwriteSaltRepositoryImpl(
          client: config.appwriteClient!,
          databaseId: config.appConfig.appwriteConfig!.databaseId,
          collectionId: config.appConfig.appwriteConfig!.saltCollectionId,
        );
    }
  }
}
