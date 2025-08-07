import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/providers/biometric_auth_available_provider.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_out.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/features/vault/application/use_cases/export_vault.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:open_password_manager/shared/presentation/sheets/export_sheet.dart';
import 'package:open_password_manager/shared/presentation/sheets/settings_sheet.dart';
import 'package:open_password_manager/shared/utils/navigation_service.dart';
import 'package:open_password_manager/shared/utils/popup_service.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserMenu extends ConsumerWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      onTap: () async {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final adjustedPosition = Offset(position.dx + 48, position.dy + 48);

        final result = await PopupService.showPopup<UserMenuSelection>(
          context,
          menuItems,
          adjustedPosition,
        );

        switch (result) {
          case UserMenuSelection.logout:
            final authRepo = ref.read(authRepositoryProvider);
            final useCase = SignOut(authRepo);
            await useCase();

            // triggers biometric auth again if supported            
            ref.invalidate(biometricAuthAvailableProvider);

            if (context.mounted) {
              ToastService.show(context, "Sign out successful!");
              await NavigationService.replaceAll(context, SignInPage());
            }
          case UserMenuSelection.settings:
            if (context.mounted) {
              await showShadSheet(
                side: ShadSheetSide.right,
                context: context,
                builder: (context) => SettingsSheet(),
              );
            }
          case UserMenuSelection.export:
            if (context.mounted) {
              await showShadSheet(
                side: ShadSheetSide.right,
                context: context,
                builder: (context) => ExportSheet(
                  onSelected: (option) =>
                      _onExportOptionSelected(context, ref, option),
                ),
              );
            }
          default:
            return;
        }
      },
      child: CircleAvatar(
        child: Text(ref.watch(opmUserProvider).user.substring(0, 2)),
      ),
    );
  }

  Future<void> _onExportOptionSelected(
    BuildContext context,
    WidgetRef ref,
    ExportOption option,
  ) async {
    final exportRepo = ref.read(exportRepositoryProvider);
    final vaultRepo = ref.read(vaultRepositoryProvider);

    final useCase = ExportVault(vaultRepo, exportRepo);
    await useCase(option);

    if (context.mounted) {
      ToastService.show(context, "Vault export completed!");
    }
  }

  List<PopupMenuEntry<UserMenuSelection>> get menuItems => [
    const PopupMenuItem(
      height: sizeL,
      value: UserMenuSelection.settings,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.settings, size: sizeS),
          Text('Settings'),
        ],
      ),
    ),
    const PopupMenuItem(
      height: sizeL,
      value: UserMenuSelection.export,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.share, size: sizeS),
          Text('Export vault'),
        ],
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      height: sizeL,
      value: UserMenuSelection.logout,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.logOut, size: sizeS),
          Text('Log out'),
        ],
      ),
    ),
  ];
}

enum UserMenuSelection { logout, settings, export }
