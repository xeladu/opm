import 'package:open_password_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:open_password_manager/features/auth/domain/repositories/biometric_auth_repository.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/appwrite_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/biometric_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/firebase_auth_repository_impl.dart';
import 'package:open_password_manager/features/auth/infrastructure/repositories/supabase_auth_repository_impl.dart';
import 'package:open_password_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:open_password_manager/features/settings/infrastructure/repositories/settings_repository_impl.dart';
import 'package:open_password_manager/features/vault/domain/repositories/export_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/import_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:open_password_manager/features/vault/domain/repositories/password_generator_repository.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/appwrite_entry_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/export/export_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/firebase_entry_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/import_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/password_generator_repository_impl.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/supabase_entry_repository_impl.dart';
import 'package:open_password_manager/shared/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/domain/repositories/clipboard_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/cryptography_repository.dart';
import 'package:open_password_manager/shared/domain/repositories/crypto_utils_repository.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/crypto_utils/appwrite_crypto_utils_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/clipboard_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/cryptography_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/crypto_utils/firebase_crypto_utils_repository_impl.dart';
import 'package:open_password_manager/shared/infrastructure/repositories/crypto_utils/supabase_crypto_utils_repository_impl.dart';
import 'package:open_password_manager/shared/utils/hosting_provider.dart';
import 'package:open_password_manager/shared/domain/entities/provider_config.dart';
import 'package:open_password_manager/shared/application/services/storage_service.dart';
import 'package:open_password_manager/shared/utils/service_factory.dart';

class RepositoryFactory {
  final ServiceFactory serviceFactory;
  RepositoryFactory(this.serviceFactory);

  AuthRepository getAuthRepository(ProviderConfig config) {
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

  ExportRepository getExportRepository() {
    return ExportRepositoryImpl.instance;
  }

  ImportRepository getImportRepository() {
    return ImportRepositoryImpl.instance;
  }

  CryptographyRepository getCryptoRepository(CryptoService cryptoService) {
    return CryptographyRepositoryImpl(cryptoService);
  }

  PasswordGeneratorRepository getPasswordGeneratorRepository() {
    return PasswordGeneratorRepositoryImpl.instance;
  }

  VaultRepository getVaultRepository(ProviderConfig config, CryptoService cryptoService) {
    final cryptoProvider = getCryptoRepository(cryptoService);

    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return FirebaseEntryRepositoryImpl(
          config: config.appConfig.firebaseConfig!,
          cryptoRepo: cryptoProvider,
        );
      case HostingProvider.supabase:
        if (config.supabaseClient == null) {
          throw Exception("Invalid supabase client configuration");
        }

        return SupabaseEntryRepositoryImpl(
          client: config.supabaseClient!,
          tableName: config.appConfig.supabaseConfig!.vaultDbName,
          cryptoRepo: cryptoProvider,
        );
      case HostingProvider.appwrite:
        if (config.appwriteClient == null) {
          throw Exception("Invalid appwrite client configuration");
        }

        return AppwriteEntryRepositoryImpl(
          client: config.appwriteClient!,
          config: config.appConfig.appwriteConfig!,
          cryptoRepo: cryptoProvider,
        );
    }
  }

  ClipboardRepository getClipboardRepository() {
    return ClipboardRepositoryImpl.instance;
  }

  CryptoUtilsRepository getCryptoUtilsRepository(ProviderConfig config) {
    switch (config.hostingProvider) {
      case HostingProvider.firebase:
        return FirebaseCryptoUtilsRepositoryImpl(
          collectionId: config.appConfig.firebaseConfig!.utilsCollectionName,
        );
      case HostingProvider.supabase:
        if (config.supabaseClient == null) {
          throw Exception("Invalid supabase client configuration");
        }
        return SupabaseCryptoUtilsRepositoryImpl(
          client: config.supabaseClient!,
          tableName: config.appConfig.supabaseConfig!.utilsDbName,
        );
      case HostingProvider.appwrite:
        if (config.appwriteClient == null) {
          throw Exception("Invalid appwrite client configuration");
        }
        return AppwriteCryptoUtilsRepositoryImpl(
          client: config.appwriteClient!,
          databaseId: config.appConfig.appwriteConfig!.databaseId,
          collectionId: config.appConfig.appwriteConfig!.utilsCollectionId,
        );
    }
  }

  BiometricAuthRepository getBiometricAuthRepository() {
    return BiometricAuthRepositoryImpl();
  }

  SettingsRepository getSettingsRepository(StorageService storage) {
    return SettingsRepositoryImpl(storage: storage);
  }
}
