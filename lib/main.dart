import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_provider.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/export_provider.dart';
import 'package:open_password_manager/features/password/infrastructure/providers/password_provider.dart';
import 'package:open_password_manager/shared/utils/bootstrapper.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bs = Bootstrapper();
  final config = await bs.loadConfig();
  final client = await bs.initBackendFromConfig(config);
  final authProvider = bs.getAuthProvider(config, client);
  final passwordProvider = bs.getPasswordProvider(config, client);
  final exportProvider = bs.getExportProvider();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authProvider),
        passwordRepositoryProvider.overrideWithValue(passwordProvider),
        exportRepositoryProvider.overrideWithValue(exportProvider),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SignInPage(),
    );
  }
}
