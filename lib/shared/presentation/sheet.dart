import 'package:flutter/material.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Sheet extends StatelessWidget {
  final String title;
  final String? description;
  final Widget content;
  final String? primaryButtonCaption;
  final String? secondaryButtonCaption;
  final bool hideSecondaryButton;
  final Future<bool> Function()? onPrimaryButtonPressed;
  final Future<bool> Function()? onSecondaryButtonPressed;

  const Sheet({
    super.key,
    required this.title,
    required this.content,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.description,
    this.primaryButtonCaption,
    this.secondaryButtonCaption,
    this.hideSecondaryButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ShadSheet(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        title: Text(title),
        description: description == null
            ? null
            : Text(description!, textAlign: TextAlign.left),
        actions: [
          if (!hideSecondaryButton)
            SecondaryButton(
              caption: secondaryButtonCaption ?? "Cancel",
              onPressed: () async => await _secondaryPressed(context),
            ),
          PrimaryButton(
            caption: primaryButtonCaption ?? "Save",
            onPressed: () async => await _primaryPressed(context),
          ),
        ],

        child: content,
      ),
    );
  }

  Future<void> _primaryPressed(BuildContext context) async {
    if (onPrimaryButtonPressed != null) {
      final result = await onPrimaryButtonPressed!();
      if (!result) return;
    }

    if (context.mounted) {
      await NavigationService.goBack(context);
    }
  }

  Future<void> _secondaryPressed(BuildContext context) async {
    if (onSecondaryButtonPressed != null) {
      final result = await onSecondaryButtonPressed!();
      if (!result) return;
    }

    if (context.mounted) {
      await NavigationService.goBack(context);
    }
  }
}
