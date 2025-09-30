import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/active_filter_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entry_folders_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_type_groups_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/custom_folder.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/shared/domain/entities/filter.dart';
import 'package:open_password_manager/shared/presentation/generic_error.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EntryFilterSheet extends ConsumerStatefulWidget {
  const EntryFilterSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<EntryFilterSheet> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ensure that data is loaded before the user opens the selection
      ref.read(allEntryFoldersProvider);
      ref.read(allTypeGroupsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customFolderContent = CustomFolderSection();
    final typeFolderContent = TypeFolderSection();

    return Sheet(
      title: "Filter",
      description: "Choose a folder or type to filter your vault.",
      primaryButtonCaption: "Close",
      hideSecondaryButton: true,
      content: Material(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [customFolderContent, ShadSeparator.horizontal(), typeFolderContent],
          ),
        ),
      ),
    );
  }
}

class CustomFolderSection extends ConsumerWidget {
  const CustomFolderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFolder = ref.watch(activeFilterProvider);
    final allFoldersState = ref.watch(allEntryFoldersProvider);

    return allFoldersState.when(
      data: (folders) {
        _addDefaultFolder(ref, folders);
        return Column(
          children: folders
              .map(
                (folder) => ListTile(
                  minTileHeight: minFolderEntryTileHeight,
                  shape: RoundedRectangleBorder(borderRadius: ShadTheme.of(context).radius),
                  contentPadding: EdgeInsets.symmetric(horizontal: sizeXS),
                  splashColor: Colors.transparent,
                  minVerticalPadding: 0,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(folder.name, style: ShadTheme.of(context).textTheme.p),
                  tileColor:
                      (selectedFolder != null && selectedFolder.name == folder.name) ||
                          (selectedFolder == null && folder.isDefaultFolder)
                      ? ShadTheme.of(context).colorScheme.accent
                      : null,
                  trailing: Text(
                    "(${folder.entryCount})",
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  onTap: () {
                    if (folder.isDefaultFolder) {
                      ref.read(activeFilterProvider.notifier).setFolder(null);
                    } else {
                      ref
                          .read(activeFilterProvider.notifier)
                          .setFolder(
                            Filter(name: folder.name, displayValue: "Folder ${folder.name}"),
                          );
                    }
                  },
                ),
              )
              .toList(),
        );
      },
      loading: () => Loading(text: "Loading", value: null),
      error: (_, _) => GenericError(),
    );
  }

  void _addDefaultFolder(WidgetRef ref, List<CustomFolder> folders) {
    if (folders.any((folder) => folder.isDefaultFolder)) return;

    folders.insert(
      0,
      CustomFolder(
        name: "All entries",
        isDefaultFolder: true,
        entryCount: ref.read(allEntriesProvider).requireValue.length,
      ),
    );
  }
}

class TypeFolderSection extends ConsumerWidget {
  const TypeFolderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFolder = ref.watch(activeFilterProvider);
    final allTypesState = ref.watch(allTypeGroupsProvider);

    return allTypesState.when(
      data: (folders) {
        return Column(
          children: folders
              .map(
                (folder) => ListTile(
                  minTileHeight: minFolderEntryTileHeight,
                  shape: RoundedRectangleBorder(borderRadius: ShadTheme.of(context).radius),
                  contentPadding: EdgeInsets.symmetric(horizontal: sizeXS),
                  splashColor: Colors.transparent,
                  minVerticalPadding: 0,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(folder.type.toNiceString(), style: ShadTheme.of(context).textTheme.p),
                  tileColor: (selectedFolder?.name == folder.type.name)
                      ? ShadTheme.of(context).colorScheme.accent
                      : null,
                  trailing: Text(
                    "(${folder.entryCount})",
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  onTap: () {
                    ref
                        .read(activeFilterProvider.notifier)
                        .setFolder(
                          Filter(name: folder.type.name, displayValue: folder.type.toNiceString()),
                        );
                  },
                ),
              )
              .toList(),
        );
      },
      loading: () => Loading(text: "Loading", value: null),
      error: (_, _) => GenericError(),
    );
  }
}
