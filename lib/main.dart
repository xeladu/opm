import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/device_auth_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/password_generator_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/app_settings_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/salt_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/generic_error.dart';
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

    final authProvider = repoFactory.getAuthProvider(providerConfig);
    final clipboardProvider = repoFactory.getClipboardProvider();
    final cryptoProvider = repoFactory.getCryptoProvider();
    final deviceAuthProvider = repoFactory.getDeviceAuthProvider();
    final exportProvider = repoFactory.getExportProvider();
    final passwordGeneratorProvider = repoFactory.getPasswordGeneratorProvider();
    final saltProvider = repoFactory.getSaltProvider(providerConfig);
    final vaultProvider = repoFactory.getPasswordProvider(providerConfig);

    runApp(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authProvider),
          clipboardRepositoryProvider.overrideWithValue(clipboardProvider),
          cryptographyRepositoryProvider.overrideWithValue(cryptoProvider),
          deviceAuthRepositoryProvider.overrideWithValue(deviceAuthProvider),
          exportRepositoryProvider.overrideWithValue(exportProvider),
          passwordGeneratorRepositoryProvider.overrideWithValue(passwordGeneratorProvider),
          saltRepositoryProvider.overrideWithValue(saltProvider),
          vaultRepositoryProvider.overrideWithValue(vaultProvider),
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
    return hasError
        ? ShadApp(
            theme: ShadThemeData(
              colorScheme: ShadNeutralColorScheme.dark(),
              brightness: Brightness.dark,
            ),
            home: Center(child: GenericError()),
          )
        : ShadApp(
            title: 'OPM - Open Password Manager',
            debugShowCheckedModeBanner: false,
            themeMode: ref.watch(appSettingsProvider.select((s) => s.themeMode)),
            theme: ShadThemeData(
              colorScheme: ref.watch(appSettingsProvider.select((s) => s.lightColorScheme)),
              textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
              brightness: Brightness.light,
            ),
            darkTheme: ShadThemeData(
              colorScheme: ref.watch(appSettingsProvider.select((s) => s.darkColorScheme)),
              textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
              brightness: Brightness.dark,
            ),
            home: const SignInPage(),
          );
  }
}
