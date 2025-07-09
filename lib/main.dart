import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_provider.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/export_provider.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/utils/bootstrapper.dart';
import 'package:open_password_manager/shared/utils/provider_config.dart';
import 'package:open_password_manager/shared/utils/provider_factory.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authProvider),
        passwordRepositoryProvider.overrideWithValue(passwordProvider),
        exportRepositoryProvider.overrideWithValue(exportProvider),
        cryptographyRepositoryProvider.overrideWithValue(cryptoProvider),
      ],
      child: const OpmApp(),
    ),
  );
}

class OpmApp extends StatelessWidget {
  const OpmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SignInPage(),
    );
  }
}
