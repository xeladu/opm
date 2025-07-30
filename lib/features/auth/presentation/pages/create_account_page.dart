import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/use_cases/create_account.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/loading_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'sign_in_page.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _State();
}

class _State extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: dialogMaxWidth),
          padding: EdgeInsets.all(sizeXL),
          child: ShadForm(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Open Password Manager",
                    style: ShadTheme.of(context).textTheme.h3,
                  ),
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
                    validator: (v) {
                      final password =
                          _formKey
                              .currentState
                              ?.fields["password_confirm"]
                              ?.value ??
                          "";
                      if (v != password) return "Passwords do not match";
                      return null;
                    },
                  ),
                  const SizedBox(height: sizeS),
                  PasswordFormField(
                    placeholder: "Confirm password",
                    validator: (v) {
                      final password =
                          _formKey.currentState?.fields["password"]?.value ??
                          "";
                      if (v != password) return "Passwords do not match";
                      return null;
                    },
                  ),
                  SizedBox(height: sizeM),
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
                          : await NavigationService.replaceCurrent(
                              context,
                              SignInPage(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateAccount() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final data = _formKey.currentState!.value;
    final password = data['password'] ?? '';

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
