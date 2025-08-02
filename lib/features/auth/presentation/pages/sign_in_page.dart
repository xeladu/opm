import 'package:flutter/material.dart';
import 'package:open_password_manager/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth >= dialogMaxWidth
            ? SignInPageDesktop()
            : SignInPageMobile();
      },
    );
  }
}

class SignInPageDesktop extends StatelessWidget {
  const SignInPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: dialogMaxWidth),
          padding: const EdgeInsets.all(sizeL),
          child: ShadCard(child: SignInForm()),
        ),
      ),
    );
  }
}

class SignInPageMobile extends StatelessWidget {
  const SignInPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: dialogMaxWidth),
          padding: const EdgeInsets.all(sizeL),
          child: SignInForm(),
        ),
      ),
    );
  }
}
