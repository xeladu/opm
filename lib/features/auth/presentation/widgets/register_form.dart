import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/use_cases/create_account.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/strength_indicator.dart';
import 'package:open_password_manager/shared/presentation/buttons/loading_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/services.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                _handleCreateAccount();
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
                  "Create a new account",
                  textAlign: TextAlign.left,
                  style: ShadTheme.of(context).textTheme.muted,
                ),
                const SizedBox(height: sizeXS),
                EmailFormField(),
                const SizedBox(height: sizeS),
                PasswordFormField(
                  placeholder: "Master Password",
                  validator: (v) {
                    final password = _formKey.currentState?.fields["confirm_master_password"]?.value ?? "";
                    if (v != password) return "Passwords do not match";
                    return null;
                  },
                  onChanged: () {
                    _formKey.currentState?.validate(
                      autoScrollWhenFocusOnInvalid: false,
                      focusOnInvalid: false,
                    );
                    setState(() {});
                  },
                ),
                const SizedBox(height: sizeS),
                PasswordFormField(
                  placeholder: "Confirm Master Password",
                  validator: (v) {
                    final password = _formKey.currentState?.fields["master_password"]?.value ?? "";
                    if (v != password) return "Passwords do not match";
                    return null;
                  },
                  onChanged: () {
                    _formKey.currentState?.validate(
                      autoScrollWhenFocusOnInvalid: false,
                      focusOnInvalid: false,
                    );
                    setState(() {});
                  },
                ),
                SizedBox(height: sizeS),
                if (_formKey.currentState != null &&
                    _formKey.currentState!.fields.containsKey("master_password") &&
                    _formKey.currentState!.fields["master_password"].toString().isNotEmpty) ...[
                  StrengthIndicator(
                    password: _formKey.currentState?.fields["master_password"]!.value.toString() ?? "",
                  ),
                  SizedBox(height: sizeS),
                ],
                Center(
                  child: _isLoading
                      ? LoadingButton.primary()
                      : PrimaryButton(
                          caption: "Create Account",
                          icon: LucideIcons.squareUserRound,
                          onPressed: _handleCreateAccount,
                        ),
                ),
                SizedBox(height: sizeS),
                Center(
                  child: SecondaryButton(
                    caption: 'Already have an account? Sign in',
                    onPressed: () async => _isLoading
                        ? null
                        : await NavigationService.replaceCurrent(context, SignInPage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateAccount() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final data = _formKey.currentState!.value;
    final password = data['master_password'] ?? '';

    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final useCase = CreateAccount(authRepo);

    try {
      await useCase(email: data['email'], password: password);

      if (mounted) {
        ToastService.show(context, 'Account created!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.show(context, 'Failed to create account: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
