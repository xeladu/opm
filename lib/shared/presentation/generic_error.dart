import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(sizeM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.cloudAlert, color: Colors.red, size: sizeXXL),
            const SizedBox(height: sizeS),
            Text(
              "Oops! Something went wrong.",
              style: ShadTheme.of(context).textTheme.h3,
            ),
            const SizedBox(height: sizeXS),
            Text(
              "An unexpected error occurred during app startup. Please try restarting the app.",
              style: ShadTheme.of(context).textTheme.p,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: sizeM),
            Text(
              "An anonymous error report was created. We are really sorry for this and try our best to solve the issue as quickly as possible!",
              style: ShadTheme.of(context).textTheme.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
