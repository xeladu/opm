import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_in.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/device_auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/create_account_page.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:open_password_manager/features/auth/application/services/crypto_service.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/domain/entities/credentials.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/salt_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/loading_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/shared/utils/log_service.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _showBiometricLogin();

    return ShadForm(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset("images/opm-banner-dark.png")),
            const SizedBox(height: sizeS),
            Text("Open Password Manager", style: ShadTheme.of(context).textTheme.h3),
            const SizedBox(height: sizeXS),
            Text(
              "Sign in to your account",
              textAlign: TextAlign.left,
              style: ShadTheme.of(context).textTheme.muted,
            ),
            const SizedBox(height: sizeXS),
            EmailFormField(),
            const SizedBox(height: sizeS),
            PasswordFormField(),
            const SizedBox(height: sizeM),
            Center(
              child: _isLoading
                  ? LoadingButton.primary()
                  : PrimaryButton(
                      caption: "Sign In",
                      icon: LucideIcons.logIn,
                      onPressed: _handleSignIn,
                    ),
            ),
            const SizedBox(height: sizeS),
            Center(
              child: SecondaryButton(
                caption: "Don't have an account? Sign up",
                onPressed: () async => _isLoading
                    ? null
                    : await NavigationService.replaceCurrent(context, CreateAccountPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignIn({String? email, String? password}) async {
    // form validation only if data comes from the form and is not passed in
    if (email == null && password == null) {
      if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = _formKey.currentState!.value;
    final authRepo = ref.read(authRepositoryProvider);
    final useCase = SignIn(authRepo);

    try {
      final String emailCredential = email ?? data['email'];
      final String passwordCredential = password ?? data['password'];
      await useCase(email: emailCredential, password: passwordCredential);

      // Get user info first
      final activeUser = await authRepo.getCurrentUser();

      // Initialize crypto with shared salt management
      final cryptoRepo = ref.read(cryptographyRepositoryProvider);
      final saltRepo = ref.read(saltRepositoryProvider);
      final cryptoService = CryptoService(cryptoRepo: cryptoRepo, saltRepo: saltRepo);

      await cryptoService.initWithSharedSalt(passwordCredential, activeUser.id);

      ref.read(opmUserProvider.notifier).setUser(activeUser);

      await _askForBiometricLoginSetup();

      if (mounted) {
        ToastService.show(context, 'Sign in successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VaultListPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.show(context, 'Failed to sign in: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showBiometricLogin() {
    ref.listen<AsyncValue<bool>>(biometricAuthAvailableProvider, (prev, next) async {
      if (next.hasValue && next.value!) {
        try {
          final credentials = await ref.read(deviceAuthRepositoryProvider).authenticate();
          if (credentials == Credentials.empty()) return;

          await _handleSignIn(email: credentials.email, password: credentials.password);
        } on Exception catch (ex, st) {
          LogService.recordFlutterFatalError(FlutterErrorDetails(exception: ex, stack: st));
          if (mounted) {
            ToastService.showError(context, "Biometric authentication failed!");
          }
        }
      }
    });
  }

  Future<void> _askForBiometricLoginSetup() async {
    try {
      final canUseBiometrics = await ref.read(deviceAuthRepositoryProvider).isSupported();
      final isAlreadySetUp = await ref.read(deviceAuthRepositoryProvider).hasStoredCredentials();

      if (!canUseBiometrics || isAlreadySetUp) return;

      if (mounted) {
        final result = await DialogService.showBiometricsSetupConfirmation(context);
        if (result != true) return;

        final email = _formKey.currentState!.value["email"];
        final password = _formKey.currentState!.value["password"];

        await ref
            .read(storageServiceProvider)
            .storeAuthCredentials(Credentials(email: email, password: password));
      }
    } on Exception catch (ex, st) {
      LogService.recordFlutterFatalError(FlutterErrorDetails(exception: ex, stack: st));
      if (mounted) {
        ToastService.showError(context, "Could not enable biometric authentication!");
      }
    }
  }
}
