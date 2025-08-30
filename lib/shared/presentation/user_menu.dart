import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/application/use_cases/sign_out.dart';
import 'package:open_password_manager/features/auth/infrastructure/providers/auth_repository_provider.dart';
import 'package:open_password_manager/features/auth/presentation/pages/sign_in_page.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/use_cases/cache_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/export_vault.dart';
import 'package:open_password_manager/features/vault/application/use_cases/import_vault.dart';
import 'package:open_password_manager/features/vault/domain/exceptions/export_exception.dart';
import 'package:open_password_manager/features/vault/domain/exceptions/import_exception.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/export_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/import_repository_provider.dart';
import 'package:open_password_manager/features/vault/infrastructure/providers/vault_provider.dart';
import 'package:open_password_manager/shared/application/providers/opm_user_provider.dart';
import 'package:open_password_manager/shared/application/providers/storage_service_provider.dart';
import 'package:open_password_manager/shared/infrastructure/providers/cryptography_repository_provider.dart';
import 'package:open_password_manager/shared/presentation/sheets/export_sheet.dart';
import 'package:open_password_manager/shared/presentation/sheets/import_sheet.dart';
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
                  onSelected: (option) => _onExportOptionSelected(context, ref, option),
                ),
              );
            }
          case UserMenuSelection.import:
            if (context.mounted) {
              await showShadSheet(
                side: ShadSheetSide.right,
                context: context,
                builder: (context) => ImportSheet(
                  onSelected: (provider, content, type) =>
                      _onImportOptionSelected(context, ref, provider, content, type),
                ),
              );
            }
          default:
            return;
        }
      },
      child: CircleAvatar(child: Text(ref.watch(opmUserProvider).user.substring(0, 2))),
    );
  }

  Future<bool> _onExportOptionSelected(
    BuildContext context,
    WidgetRef ref,
    ExportOption option,
  ) async {
    try {
      final exportRepo = ref.read(exportRepositoryProvider);
      final vaultRepo = ref.read(vaultRepositoryProvider);

      final useCase = ExportVault(vaultRepo, exportRepo);
      await useCase(option);

      if (context.mounted) {
        ToastService.show(context, "Vault export completed!");
      }
      return true;
    } on ExportException catch (ex) {
      if (context.mounted) {
        ToastService.showError(context, ex.message);
      }
      return false;
    } on Exception catch (ex) {
      if (context.mounted) {
        ToastService.showError(context, ex.toString());
      }
      return false;
    }
  }

  Future<bool> _onImportOptionSelected(
    BuildContext context,
    WidgetRef ref,
    ImportProvider provider,
    String fileContent,
    String fileType,
  ) async {
    try {
      final importRepo = ref.read(importRepositoryProvider);
      final vaultRepo = ref.read(vaultRepositoryProvider);

      final useCase = ImportVault(vaultRepo, importRepo);
      await useCase(provider, fileContent, fileType);

      ref.invalidate(allEntriesProvider);

      // update cache
      final storageService = ref.read(storageServiceProvider);
      final cryptoRepo = ref.read(cryptographyRepositoryProvider);
      final allEntries = await ref.read(allEntriesProvider.future);
      await CacheVault(storageService, cryptoRepo).call(allEntries);

      if (context.mounted) {
        ToastService.show(context, "Vault import completed!");
      }
      return true;
    } on ImportException catch (ex) {
      if (context.mounted) {
        ToastService.showError(context, ex.message);
      }
      return false;
    } on Exception catch (ex) {
      if (context.mounted) {
        ToastService.showError(context, ex.toString());
      }
      return false;
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
      value: UserMenuSelection.import,
      child: Row(
        spacing: sizeXS,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.import, size: sizeS),
          Text('Import vault'),
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

enum UserMenuSelection { logout, settings, import, export }
