import 'package:flutter/material.dart';
import 'package:open_password_manager/features/auth/presentation/widgets/register_form.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth >= dialogMaxWidth
            ? CreateAccoutPageDesktop()
            : CreateAccoutPageMobile();
      },
    );
  }
}

class CreateAccoutPageMobile extends StatelessWidget {
  const CreateAccoutPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: dialogMaxWidth),
          padding: EdgeInsets.all(sizeL),
          child: RegisterForm(),
        ),
      ),
    );
  }
}

class CreateAccoutPageDesktop extends StatelessWidget {
  const CreateAccoutPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: dialogMaxWidth),
          padding: EdgeInsets.all(sizeL),
          child: ShadCard(child: RegisterForm()),
        ),
      ),
    );
  }
}
