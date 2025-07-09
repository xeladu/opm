import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/infrastructure/auth_provider.dart';
import 'package:open_password_manager/features/password/presentation/pages/password_list_page.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/style/sizes.dart';
import 'create_account_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _State();
}

class _State extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

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

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PasswordListPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sign in: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(sizeS),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: sizeS),
                  FormBuilderTextField(
                    name: 'password',
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(8),
                    ]),
                  ),
                  const SizedBox(height: sizeM),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: sizeS),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountPage(),
                        ),
                      );
                    },
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
