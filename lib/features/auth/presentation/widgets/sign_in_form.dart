import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/auth/application/use_cases/biometric_sign_in.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_in.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/biometric_auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/create_account_page.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/shared/application/providers/crypto_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
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

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final data = _formKey.currentState!.value;
    final authRepo = ref.read(authRepositoryProvider);
    final useCase = SignIn(authRepo);

    try {
      final String emailCredential = data['email'];
      final String passwordCredential = data['password'];
      await useCase(email: emailCredential, password: passwordCredential);

      // Get user info first
      final activeUser = await authRepo.getCurrentUser();
      ref.read(opmUserProvider.notifier).setUser(activeUser);

      final enableBiometricSignIn = await _askForBiometricLoginSetup();

      final cryptoService = ref.read(cryptoServiceProvider);
      await cryptoService.init(activeUser.id, data['password'], enableBiometricSignIn);

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
          final authRepo = ref.read(authRepositoryProvider);
          final biometricAuthRepo = ref.read(biometricAuthRepositoryProvider);

          final useCase = BiometricSignIn(authRepo, biometricAuthRepo);
          final didAuthenticate = await useCase();

          if (!didAuthenticate) return;

          final activeUser = await authRepo.getCurrentUser();
          ref.read(opmUserProvider.notifier).setUser(activeUser);

          final cryptoService = ref.read(cryptoServiceProvider);
          await cryptoService.init(activeUser.id, null, true);

          if (mounted) {
            ToastService.show(context, 'Sign in successful!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const VaultListPage()),
            );
          }
        } on Exception catch (ex, st) {
          LogService.recordFlutterFatalError(FlutterErrorDetails(exception: ex, stack: st));
          if (mounted) {
            ToastService.showError(context, "Biometric authentication failed!");
          }
        }
      }
    });
  }

  Future<bool> _askForBiometricLoginSetup() async {
    final biometricAuthRepo = ref.read(biometricAuthRepositoryProvider);
    final appSettings = ref.read(settingsProvider);

    try {
      final canUseBiometrics = await biometricAuthRepo.isSupported();
      if (!canUseBiometrics) return false;

      final isAlreadySetUp = appSettings.biometricAuthEnabled;
      if (isAlreadySetUp) return true;

      if (mounted) {
        final result = await DialogService.showBiometricsSetupConfirmation(context);
        if (result != true) return false;

        final currentSettings = appSettings;
        ref
            .read(settingsProvider.notifier)
            .setSettings(currentSettings.copyWith(newBiometricAuthEnabled: true));
      }

      return true;
    } on Exception catch (ex, st) {
      LogService.recordFlutterFatalError(FlutterErrorDetails(exception: ex, stack: st));
      if (mounted) {
        ToastService.showError(context, "Could not enable biometric authentication!");
      }

      return false;
    }
  }
}
