import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/auth/application/use_cases/biometric_sign_in.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_in.dart';
import 'package:open_password_manager/features/auth/domain/entities/offline_auth_data.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/biometric_auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/create_account_page.dart';
import 'package:open_password_manager/features/vault/application/providers/active_folder_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/add_edit_mode_active_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entry_folders_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/has_changes_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/selected_entry_provider.dart';
import 'package:open_password_manager/features/vault/presentation/pages/vault_list_page.dart';
import 'package:open_password_manager/features/settings/infrastructure/providers/settings_provider.dart';
import 'package:open_password_manager/shared/application/providers/crypto_service_provider.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';
import 'package:open_password_manager/shared/application/providers/connection_listener_provider.dart';
import 'package:open_password_manager/shared/application/providers/offline_mode_available_provider.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:open_password_manager/shared/application/providers/selected_folder_provider.dart';
import 'package:open_password_manager/shared/application/providers/show_search_field_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/domain/entities/crypto_utils.dart';
import 'package:open_password_manager/shared/presentation/buttons/loading_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:open_password_manager/shared/utils/crypto_helper.dart';
import 'package:open_password_manager/shared/utils/dialog_service.dart';
import 'package:open_password_manager/shared/utils/guard.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/services.dart';

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLoading = false;
  bool _offlineModeAvailable = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOfflineMode();
    });
  }

  @override
  void didUpdateWidget(covariant SignInForm oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOfflineMode();
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOfflineMode();
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _showBiometricLogin();

    return ShadForm(
      key: _formKey,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<Intent>(
              onInvoke: (intent) {
                // Trigger primary button action when Enter is pressed.
                _handleSignIn();
                return null;
              },
            ),
          },
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
                PasswordFormField(placeholder: "Master Password"),
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
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    if (!ref.read(noConnectionProvider)) {
      await _handleOnlineSignIn();
      return;
    }

    if (_offlineModeAvailable) {
      await _handleOfflineSignIn();
      return;
    }

    ToastService.showError(
      context,
      "No internet connection. Check your device's network settings.",
    );
  }

  Future<void> _handleOnlineSignIn() async {
    await runGuarded(
      context: context,
      errorMessage: 'Email and/or master password incorrect!',
      action: () async {
        setState(() {
          _isLoading = true;
        });

        final data = _formKey.currentState!.value;
        final authRepo = ref.read(authRepositoryProvider);
        final useCase = SignIn(authRepo);

        final String emailCredential = data['email'];
        final String passwordCredential = data['master_password'];
        await useCase(email: emailCredential, password: passwordCredential);

        _resetProviders();

        // Get user info first
        final activeUser = await authRepo.getCurrentUser();
        ref.read(opmUserProvider.notifier).setUser(activeUser);

        final enableBiometricSignIn = await _askForBiometricLoginSetup();

        final cryptoService = ref.read(cryptoServiceProvider);
        await cryptoService.init(activeUser.id, passwordCredential, enableBiometricSignIn);

        // Export offline crypto utils encrypted with a key derived from the password
        // and persist it
        final offlineCryptoUtils = await cryptoService.exportOfflineCryptoUtils(passwordCredential);
        await ref.read(storageServiceProvider).storeOfflineCryptoUtils(offlineCryptoUtils);

        ref
            .read(storageServiceProvider)
            .storeOfflineAuthData(
              OfflineAuthData(
                salt: offlineCryptoUtils.salt,
                kdf: CryptoHelper.kdfParams(),
                email: emailCredential,
              ),
            );

        if (mounted) {
          ToastService.show(context, 'Sign in successful!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VaultListPage()),
          );
        }
      },
      onFinally: () async {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _handleOfflineSignIn() async {
    await runGuarded(
      context: context,
      errorMessage: 'Email and/or master password incorrect!',
      action: () async {
        setState(() {
          _isLoading = true;
        });

        final data = _formKey.currentState!.value;
        final String emailCredential = data['email'];
        final String passwordCredential = data['master_password'];

        final storageService = ref.read(storageServiceProvider);
        final offlineAuthData = await storageService.loadOfflineAuthData();
        final offlineCryptoUtils = await storageService.loadOfflineCryptoUtils();

        if (offlineAuthData == OfflineAuthData.empty() ||
            offlineCryptoUtils == CryptoUtils.empty()) {
          if (mounted) ToastService.showError(context, "No offline credentials available.");
          return;
        }

        // Ensure the email matches the stored offline record
        if (offlineAuthData.email.toLowerCase() != emailCredential.toLowerCase()) {
          if (mounted) ToastService.showError(context, "No offline credentials for this email.");
          return;
        }

        _resetProviders();

        final cryptoService = ref.read(cryptoServiceProvider);
        await cryptoService.initWithOfflineCryptoUtils(offlineCryptoUtils, passwordCredential);

        if (mounted) {
          ToastService.show(context, 'Sign in successful!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VaultListPage()),
          );
        }
      },
      onFinally: () async {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _checkOfflineMode() async {
    // Check if offline mode is supported (required data has been cached before)
    final offlineModeAvailable = await ref.watch(offlineModeAvailableProvider.future);
    setState(() {
      _offlineModeAvailable = offlineModeAvailable;
    });

    // Check if internet connection is available or not.
    // Start the connection listener side-effect provider so it begins
    // updating `noConnectionProvider` and then listen to `noConnectionProvider`.
    ref.read(connectionListenerProvider);
  }

  void _showBiometricLogin() {
    ref.listen<AsyncValue<bool>>(biometricAuthAvailableProvider, (prev, next) async {
      if (next.hasValue && next.value!) {
        await runGuarded(
          context: context,
          errorMessage: "Biometric authentication failed!",
          action: () async {
            final isSettingEnabled = ref.read(settingsProvider).biometricAuthEnabled;
            if (!isSettingEnabled) return;

            final authRepo = ref.read(authRepositoryProvider);
            final biometricAuthRepo = ref.read(biometricAuthRepositoryProvider);

            final useCase = BiometricSignIn(authRepo, biometricAuthRepo);
            final didAuthenticate = await useCase();

            if (!didAuthenticate) return;

            _resetProviders();

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
          },
        );
      }
    });
  }

  Future<bool> _askForBiometricLoginSetup() async {
    final biometricAuthRepo = ref.read(biometricAuthRepositoryProvider);
    final appSettings = ref.read(settingsProvider);

    bool initializeBiometrics = false;

    await runGuarded(
      context: context,
      errorMessage: 'Email and/or master password incorrect!',
      action: () async {
        final canUseBiometrics = await biometricAuthRepo.isSupported();
        if (!canUseBiometrics) {
          initializeBiometrics = false;
          return;
        }

        final isAlreadySetUp = appSettings.biometricAuthEnabled;
        if (isAlreadySetUp) {
          initializeBiometrics = true;
          return;
        }

        if (mounted) {
          final result = await DialogService.showBiometricsSetupConfirmation(context);
          if (result != true) {
            initializeBiometrics = false;
            return;
          }

          final currentSettings = appSettings;
          ref
              .read(settingsProvider.notifier)
              .setSettings(currentSettings.copyWith(newBiometricAuthEnabled: true));
        }

        initializeBiometrics = true;
      },
      onException: () async {
        initializeBiometrics = false;
      },
    );

    return initializeBiometrics;
  }

  void _resetProviders() {
    ref.invalidate(allEntriesProvider);
    ref.invalidate(activeFolderProvider);
    ref.invalidate(addEditModeActiveProvider);
    ref.invalidate(allEntryFoldersProvider);
    ref.invalidate(filterQueryProvider);
    ref.invalidate(hasChangesProvider);
    ref.invalidate(selectedEntryProvider);
    ref.invalidate(opmUserProvider);
    ref.invalidate(selectedFolderProvider);
    ref.invalidate(showSearchFieldProvider);
  }
}
