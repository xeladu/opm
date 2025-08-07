import 'package:flutter/widgets.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DialogService {
  /// Shows a cancel confirmation dialog.
  ///
  /// Returns `true` if the cancel is confirmed and `false`/`null` otherwise
  static Future<bool?> showCancelDialog(BuildContext context) async {
    return await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Unsaved Changes'),
        description: const Text(
          'Are you sure you want to cancel your operation?\r\nUnsaved changes will be lost!',
        ),
        actions: [
          SecondaryButton(onPressed: () => Navigator.of(context).pop(false), caption: "Stay"),
          PrimaryButton(onPressed: () => Navigator.of(context).pop(true), caption: "Leave"),
        ],
      ),
    );
  }

  /// Shows a delete confirmation dialog.
  ///
  /// Returns `true` if the deletion is confirmed and `false`/`null` otherwise
  static Future<bool?> showDeleteDialog(BuildContext context) async {
    return await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Delete Entry'),
        description: const Text(
          'Are you sure you want to delete this password entry?\r\nThis action cannot be undone!',
        ),
        actions: [
          SecondaryButton(onPressed: () => Navigator.of(context).pop(false), caption: "Cancel"),
          PrimaryButton(onPressed: () => Navigator.of(context).pop(true), caption: "Delete"),
        ],
      ),
    );
  }

  /// Shows a biometrics setup confirmation dialog.
  ///
  /// Returns `true` if confirmed and `false`/`null` otherwise
  static Future<bool?> showBiometricsSetupConfirmation(BuildContext context) async {
    return await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Biometrics Authentication'),
        description: const Text(
          'Your device supports biometric authentication. Do you want to use it instead of your email and password?\n\nEmail and password authentication will always be available.',
        ),
        actions: [
          SecondaryButton(onPressed: () => Navigator.of(context).pop(false), caption: "Skip for now"),
          PrimaryButton(onPressed: () => Navigator.of(context).pop(true), caption: "Enable"),
        ],
      ),
    );
  }
}
