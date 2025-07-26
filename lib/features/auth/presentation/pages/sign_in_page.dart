import 'package:flutter/material.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_provider.dart';
import 'package:open_password_manager/features/password/presentation/pages/password_list_page.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/shared/presentation/buttons/loading_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/inputs/email_form_field.dart';
import 'package:open_password_manager/shared/presentation/inputs/password_form_field.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'create_account_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _State();
}

class _State extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppFrame(
      content: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(sizeS),
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountPage(),
                          ),
                        );
                      },
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

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final data = _formKey.currentState!.value;
    final authRepo = ref.read(authRepositoryProvider);
    final useCase = SignIn(authRepo);

    try {
      await useCase(email: data['email'], password: data['password']);

      final cryptService = ref.read(cryptographyRepositoryProvider);
      await cryptService.init(data["password"]);

      final activeUser = await authRepo.getCurrentUser();
      ref.read(opmUserProvider.notifier).setUser(activeUser);

      if (mounted) {
        ToastService.show(context, 'Sign in successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PasswordListPage()),
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
}
