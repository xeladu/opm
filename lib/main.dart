import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/password_generator_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/app_settings_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/clipboard_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/salt_repository_provider.dart';
import 'package:open_password_manager/shared/utils/bootstrapper.dart';
import 'package:open_password_manager/shared/domain/entities/provider_config.dart';
import 'package:open_password_manager/shared/utils/provider_factory.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrapper = Bootstrapper();
  await bootstrapper.initBackendFromConfig();

  final providerConfig = ProviderConfig(
    appConfig: bootstrapper.appConfig,
    hostingProvider: bootstrapper.provider,
    supabaseClient: bootstrapper.supabaseClient,
    appwriteClient: bootstrapper.appwriteClient,
  );

  final authProvider = ProviderFactory.getAuthProvider(providerConfig);
  final passwordProvider = ProviderFactory.getPasswordProvider(providerConfig);
  final cryptoProvider = ProviderFactory.getCryptoProvider();
  final exportProvider = ProviderFactory.getExportProvider();
  final clipboardProvider = ProviderFactory.getClipboardProvider();
  final saltProvider = ProviderFactory.getSaltProvider(providerConfig);
  final passwordGeneratorProvider =
      ProviderFactory.getPasswordGeneratorProvider();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authProvider),
        vaultRepositoryProvider.overrideWithValue(passwordProvider),
        exportRepositoryProvider.overrideWithValue(exportProvider),
        cryptographyRepositoryProvider.overrideWithValue(cryptoProvider),
        clipboardRepositoryProvider.overrideWithValue(clipboardProvider),
        saltRepositoryProvider.overrideWithValue(saltProvider),
        passwordGeneratorRepositoryProvider.overrideWithValue(
          passwordGeneratorProvider,
        ),
      ],
      child: const OpmApp(),
    ),
  );
}

class OpmApp extends ConsumerWidget {
  const OpmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(appSettingsProvider.select((s) => s.themeMode)),
      theme: ShadThemeData(
        colorScheme: ref.watch(
          appSettingsProvider.select((s) => s.lightColorScheme),
        ),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
        brightness: Brightness.light,
      ),
      darkTheme: ShadThemeData(
        colorScheme: ref.watch(
          appSettingsProvider.select((s) => s.darkColorScheme),
        ),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.inter),
        brightness: Brightness.dark,
      ),
      home: const SignInPage(),
    );
  }
}
