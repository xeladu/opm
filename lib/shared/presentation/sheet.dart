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
  final Future<void> Function() onConfirm;
  final Future<void> Function()? onCancel;

  const Sheet({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.description,
    this.primaryButtonCaption,
    this.secondaryButtonCaption,
  });

  @override
  Widget build(BuildContext context) {
    return ShadSheet(
      constraints: BoxConstraints(maxWidth: dialogMaxWidth),
      title: Text(title),
      description: description == null
          ? null
          : Text(description!, textAlign: TextAlign.left),
      actions: [
        SecondaryButton(
          caption: secondaryButtonCaption ?? "Cancel",
          onPressed: () async => await _cancel(context),
        ),
        PrimaryButton(
          caption: primaryButtonCaption ?? "Save",
          onPressed: () async => await _confirm(context),
        ),
      ],
      
      child: content,
    );
  }

  Future<void> _confirm(BuildContext context) async {
    await onConfirm();

    if (context.mounted) {
      await NavigationService.goBack(context);
    }
  }

  Future<void> _cancel(BuildContext context) async {
    if (onCancel != null) await onCancel!();

    if (context.mounted) {
      await NavigationService.goBack(context);
    }
  }
}
