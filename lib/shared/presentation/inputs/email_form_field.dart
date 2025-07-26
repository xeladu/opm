import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmailFormField extends StatelessWidget {
  const EmailFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      id: "email",
      keyboardType: TextInputType.emailAddress,
      placeholder: const Text('Email'),
      leading: const Padding(
        padding: EdgeInsets.all(sizeXXS),
        child: Icon(LucideIcons.mail),
      ),
      validator: (v) {
        if (v.isEmpty) return "Please enter a value";

        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
        if (!emailRegex.hasMatch(v)) return "Invalid email";

        return null;
      },
    );
  }
}
