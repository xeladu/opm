import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoadingButton extends StatelessWidget {
  final String? caption;
  final bool isPrimary;

  const LoadingButton._({this.caption, required this.isPrimary});

  const LoadingButton.primary({String? caption})
    : this._(caption: caption, isPrimary: true);

  const LoadingButton.secondary({String? caption})
    : this._(caption: caption, isPrimary: false);

  @override
  Widget build(BuildContext context) {
    return isPrimary
        ? ShadButton(
            onPressed: () {},
            leading: SizedBox.square(
              dimension: sizeS,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ShadTheme.of(context).colorScheme.primaryForeground,
              ),
            ),
            child: Text(caption ?? "Please wait"),
          )
        : ShadButton.secondary(
            onPressed: () {},
            leading: SizedBox.square(
              dimension: sizeS,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ShadTheme.of(context).colorScheme.primaryForeground,
              ),
            ),
            child: Text(caption ?? "Please wait"),
          );
  }
}
