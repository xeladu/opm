import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_providers.dart';
import 'package:open_password_manager/shared/utils/bootstrapper.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bs = Bootstrapper();
  final config = await bs.loadConfig();
  final appClient = await bs.initBackendFromConfig(config);
  final authProvider = bs.getAuthProvider(config, appClient);

  runApp(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(authProvider)],
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
