import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_license_manager/flutter_license_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entry_folders_provider.dart';
import 'package:open_password_manager/shared/application/providers/package_info_service_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/license_list.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogService {
  /// Shows a cancel confirmation dialog.
  ///
  /// Returns `true` if the cancel is confirmed and `false`/`null` otherwise
  static Future<bool?> showCancelDialog(BuildContext context) async {
    return await showShadDialog<bool>(
      context: context,
      builder: (context) {
        // Define actions to be reused by buttons and keyboard handler
        void onSecondary() => Navigator.of(context).pop(false);
        void onPrimary() => Navigator.of(context).pop(true);

        return _DialogKeyboardWrapper(
          onPrimary: onPrimary,
          onSecondary: onSecondary,
          child: ShadDialog.alert(
            title: const Text('Unsaved Changes'),
            description: const Text(
              'Are you sure you want to cancel your operation?\r\nUnsaved changes will be lost!',
            ),
            actions: [
              SecondaryButton(onPressed: onSecondary, caption: "Stay"),
              PrimaryButton(onPressed: onPrimary, caption: "Leave"),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            descriptionTextAlign: TextAlign.start,
          ),
        );
      },
    );
  }

  /// Shows a delete confirmation dialog.
  ///
  /// Returns `true` if the deletion is confirmed and `false`/`null` otherwise
  static Future<bool?> showDeleteDialog(BuildContext context) async {
    return await showShadDialog<bool>(
      context: context,
      builder: (context) {
        void onSecondary() => Navigator.of(context).pop(false);
        void onPrimary() => Navigator.of(context).pop(true);

        return _DialogKeyboardWrapper(
          onPrimary: onPrimary,
          onSecondary: onSecondary,
          child: ShadDialog.alert(
            title: const Text('Delete Entry'),
            description: const Text(
              'Are you sure you want to delete this password entry?\r\nThis action cannot be undone!',
            ),
            actions: [
              SecondaryButton(onPressed: onSecondary, caption: "Cancel"),
              PrimaryButton(onPressed: onPrimary, caption: "Delete"),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            descriptionTextAlign: TextAlign.start,
          ),
        );
      },
    );
  }

  /// Shows a biometrics setup confirmation dialog.
  ///
  /// Returns `true` if confirmed and `false`/`null` otherwise
  static Future<bool?> showBiometricsSetupConfirmation(BuildContext context) async {
    return await showShadDialog<bool>(
      context: context,
      builder: (context) {
        void onSecondary() => Navigator.of(context).pop(false);
        void onPrimary() => Navigator.of(context).pop(true);

        return _DialogKeyboardWrapper(
          onPrimary: onPrimary,
          onSecondary: onSecondary,
          child: ShadDialog.alert(
            title: const Text('Biometrics Authentication'),
            description: const Text(
              'Your device supports biometric authentication. Do you want to use it instead of your email and password?\n\nEmail and password authentication will always be available.',
            ),
            actions: [
              SecondaryButton(onPressed: onSecondary, caption: "Skip for now"),
              PrimaryButton(onPressed: onPrimary, caption: "Enable"),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            descriptionTextAlign: TextAlign.start,
          ),
        );
      },
    );
  }

  /// Shows an input dialog to create a folder.
  ///
  /// Returns `true` if confirmed and `false`/`null` otherwise
  static Future<String?> showFolderCreationDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<ShadFormState>();
    final ctrl = TextEditingController();
    final folders = await ref.read(allEntryFoldersProvider.future);

    if (context.mounted) {
      final result = await showShadDialog<String?>(
        context: context,
        builder: (context) {
          void onSecondary() => Navigator.of(context).pop(null);
          void onPrimary() {
            if (formKey.currentState!.saveAndValidate()) {
              Navigator.of(context).pop(ctrl.text);
            }
          }

          return _DialogKeyboardWrapper(
            onPrimary: onPrimary,
            onSecondary: onSecondary,
            child: ShadDialog.alert(
              title: const Text('Create new folder'),
              description: const Text(
                'Choose the name of your new folder. It will be available for selection.',
              ),
              actions: [
                SecondaryButton(onPressed: onSecondary, caption: "Cancel"),
                PrimaryButton(onPressed: onPrimary, caption: "Add"),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              descriptionTextAlign: TextAlign.start,
              child: ShadForm(
                key: formKey,
                child: ShadInputFormField(
                  controller: ctrl,
                  validator: (input) {
                    if (input.isEmpty) {
                      return "Please enter a name!";
                    }

                    if (folders.any((folder) => folder.name == input)) {
                      return "This folder already exists!";
                    }

                    if (input == 'All entries') {
                      return "'All entries' is a reserved folder name.";
                    }

                    return null;
                  },
                ),
              ),
            ),
          );
        },
      );

      ctrl.dispose();

      return result;
    }

    return null;
  }

  /// Shows an info dialog with details about offline mode.
  static Future<void> showNoConnectionDialog(BuildContext context) async {
    if (context.mounted) {
      await showShadDialog<String?>(
        context: context,
        builder: (context) {
          void onPrimary() => Navigator.of(context).pop();

          return _DialogKeyboardWrapper(
            onPrimary: onPrimary,
            child: ShadDialog.alert(
              title: const Text('No Internet Connection'),
              description: const Text(
                'Your device is not connected to the internet. The app is in read-only mode. You can still see and copy your data, but you cannot add, delete, or change anything until the connection is restored.',
              ),
              actions: [PrimaryButton(onPressed: onPrimary, caption: "Close")],
              crossAxisAlignment: CrossAxisAlignment.start,
              descriptionTextAlign: TextAlign.start,
            ),
          );
        },
      );
    }
  }

  /// Shows an about dialog with details about the app.
  static Future<void> showAboutDialog(BuildContext context, WidgetRef ref) async {
    final pi = await ref.read(packageInfoServiceProvider).getPackageInfo();
    final appVersion = pi.version;

    if (context.mounted) {
      await showShadDialog<String?>(
        context: context,
        builder: (context) {
          void onPrimary() => Navigator.of(context).pop();

          return _DialogKeyboardWrapper(
            onPrimary: onPrimary,
            child: ShadDialog.alert(
              title: const Text('About OPM'),
              description: Text(
                'Open Password Manager - An open source alternative with encrypted cloud storage for various hosters (v$appVersion)',
              ),
              actions: [PrimaryButton(onPressed: onPrimary, caption: "Close")],
              crossAxisAlignment: CrossAxisAlignment.start,
              descriptionTextAlign: TextAlign.start,
              child: Column(
                spacing: sizeXS,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SecondaryButton(
                        caption: "Learn more",
                        onPressed: () async {
                          await launchUrl(Uri.parse("https://opm.quickcoder.org/"));
                        },
                      ),
                      SecondaryButton(
                        caption: "Show code",
                        onPressed: () async {
                          await launchUrl(Uri.parse("https://github.com/xeladu/opm"));
                        },
                      ),
                      SecondaryButton(
                        caption: "View licenses",
                        onPressed: () async {
                          await showLicenseDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: sizeXS),
                  Text("Delete account", style: ShadTheme.of(context).textTheme.large),
                  Text(
                    "To delete your account, proceed to the website below and follow the instructions.",
                  ),
                  Center(
                    child: SecondaryButton(
                      caption: "Request account removal",
                      onPressed: () async {
                        await launchUrl(Uri.parse("https://opm.quickcoder.org/#data-deletion"));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  /// Shows a license with details about the used packages.
  static Future<void> showLicenseDialog(BuildContext context) async {
    final licenses = await LicenseService.loadFromLicenseRegistry();
    if (context.mounted) {
      await showShadDialog<String?>(
        context: context,
        builder: (context) {
          void onPrimary() => Navigator.of(context).pop();

          return _DialogKeyboardWrapper(
            onPrimary: onPrimary,
            child: ShadDialog.alert(
              title: const Text('Licenses'),
              actions: [PrimaryButton(onPressed: onPrimary, caption: "Close")],
              crossAxisAlignment: CrossAxisAlignment.start,
              child: Material(child: LicenseList(licenses: licenses)),
            ),
          );
        },
      );
    }
  }
}

/// Internal widget that maps Enter -> primary action and Escape -> secondary action.
class _DialogKeyboardWrapper extends StatelessWidget {
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final Widget child;

  const _DialogKeyboardWrapper({required this.onPrimary, required this.child, this.onSecondary});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (intent) {
              onPrimary();
              return null;
            },
          ),
          DismissIntent: CallbackAction<Intent>(
            onInvoke: (intent) {
              if (onSecondary != null) onSecondary!();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
