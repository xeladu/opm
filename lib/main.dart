import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/biometric_auth_repository_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/import_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/password_generator_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/shared/application/providers/crypto_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/file_picker_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/init_provider.dart';
import 'package:open_password_manager/shared/application/providers/package_info_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/crypto_utils_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/generic_error.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/utils/bootstrapper.dart';
import 'package:open_password_manager/shared/domain/entities/provider_config.dart';
import 'package:open_password_manager/shared/utils/log_service.dart';
import 'package:open_password_manager/shared/utils/repository_factory.dart';
import 'package:open_password_manager/shared/utils/service_factory.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = LogService.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (dynamic error, StackTrace? stackTrace) {
      LogService.recordFlutterFatalError(FlutterErrorDetails(exception: error, stack: stackTrace));

      return true;
    };

    final bootstrapper = Bootstrapper();
    await bootstrapper.initBackendFromConfig();

    final providerConfig = ProviderConfig(
      appConfig: bootstrapper.appConfig,
      hostingProvider: bootstrapper.provider,
      supabaseClient: bootstrapper.supabaseClient,
      appwriteClient: bootstrapper.appwriteClient,
    );

    final serviceFactory = ServiceFactory();
    final repoFactory = RepositoryFactory(serviceFactory);

    final cryptoUtilsProvider = repoFactory.getCryptoUtilsRepository(providerConfig);
    final filePickerService = serviceFactory.getFilePickerService();
    final storageService = serviceFactory.getStorageService();
    final cryptoService = serviceFactory.getCryptoService(cryptoUtilsProvider, storageService);
    final packageInfoService = serviceFactory.getPackageInfoService();

    final autoRepo = repoFactory.getAuthRepository(providerConfig);
    final clipboardRepo = repoFactory.getClipboardRepository();
    final cryptoRepo = repoFactory.getCryptoRepository(cryptoService);
    final biometricAuthRepo = repoFactory.getBiometricAuthRepository();
    final exportRepo = repoFactory.getExportRepository();
    final importRepo = repoFactory.getImportRepository();
    final passwordGeneratorRepo = repoFactory.getPasswordGeneratorRepository();
    final settingsRepo = repoFactory.getSettingsRepository(storageService);
    final vaultRepo = repoFactory.getVaultRepository(providerConfig, cryptoService);

    runApp(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(autoRepo),
          biometricAuthRepositoryProvider.overrideWithValue(biometricAuthRepo),
          clipboardRepositoryProvider.overrideWithValue(clipboardRepo),
          cryptographyRepositoryProvider.overrideWithValue(cryptoRepo),
          cryptoServiceProvider.overrideWithValue(cryptoService),
          cryptoUtilsRepositoryProvider.overrideWithValue(cryptoUtilsProvider),
          exportRepositoryProvider.overrideWithValue(exportRepo),
          filePickerServiceProvider.overrideWithValue(filePickerService),
          importRepositoryProvider.overrideWithValue(importRepo),
          packageInfoServiceProvider.overrideWithValue(packageInfoService),
          passwordGeneratorRepositoryProvider.overrideWithValue(passwordGeneratorRepo),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          storageServiceProvider.overrideWithValue(storageService),
          vaultRepositoryProvider.overrideWithValue(vaultRepo),
        ],
        child: const OpmApp(),
      ),
    );
  } catch (ex, st) {
    LogService.recordFlutterFatalError(FlutterErrorDetails(exception: ex, stack: st));

    runApp(const OpmApp.error());
  }
}

class OpmApp extends ConsumerWidget {
  final bool hasError;

  const OpmApp({super.key, this.hasError = false});

  const OpmApp.error({Key? key}) : this(key: key, hasError: true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hasError) {
      return ShadApp(
        theme: ShadThemeData(
          colorScheme: ShadNeutralColorScheme.dark(),
          brightness: Brightness.dark,
        ),
        home: Center(child: GenericError()),
      );
    }

    final initState = ref.watch(initProvider);

    return ShadApp(
      title: 'OPM - Open Password Manager',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(settingsProvider.select((s) => s.themeMode)),
      theme: ShadThemeData(
        colorScheme: ref.watch(settingsProvider.select((s) => s.lightColorScheme)),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
        brightness: Brightness.light,
      ),
      darkTheme: ShadThemeData(
        colorScheme: ref.watch(settingsProvider.select((s) => s.darkColorScheme)),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
        brightness: Brightness.dark,
      ),
      home: initState.when(
        data: (_) => const SignInPage(),
        loading: () => Loading(),
        error: (_, _) => ShadApp(
          theme: ShadThemeData(
            colorScheme: ShadNeutralColorScheme.dark(),
            brightness: Brightness.dark,
          ),
          home: Center(child: GenericError()),
        ),
      ),
    );
  }
}
