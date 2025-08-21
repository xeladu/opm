import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/providers/active_folder_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entries_provider.dart';
import 'package:open_password_manager/features/vault/application/providers/all_entry_folders_provider.dart';
import 'package:open_password_manager/features/vault/domain/entities/folder.dart';
import 'package:open_password_manager/shared/presentation/generic_error.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FolderSheet extends ConsumerStatefulWidget {
  const FolderSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<FolderSheet> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ensure that folders are loaded before the user opens the selection
      ref.read(allEntryFoldersProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFolder = ref.watch(activeFolderProvider);
    final allFoldersState = ref.watch(allEntryFoldersProvider);

    final content = allFoldersState.when(
      data: (folders) {
        _addDefaultFolder(folders);
        return folders
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
                    (selectedFolder == folder.name) ||
                        (selectedFolder.isEmpty && folder.isDefaultFolder)
                    ? ShadTheme.of(context).colorScheme.accent
                    : null,
                trailing: Text(
                  "(${folder.entryCount})",
                  style: ShadTheme.of(context).textTheme.muted,
                ),
                onTap: () {
                  if (folder.isDefaultFolder) {
                    ref.read(activeFolderProvider.notifier).setFolder("");
                  } else {
                    ref.read(activeFolderProvider.notifier).setFolder(folder.name);
                  }
                },
              ),
            )
            .toList();
      },
      loading: () => [Loading(text: "Loading", value: null)],
      error: (_, _) => [GenericError()],
    );

    return Sheet(
      title: "Folders",
      description: "Choose a folder to see its content.",
      primaryButtonCaption: "Close",
      hideSecondaryButton: true,
      content: Material(
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: content),
        ),
      ),
    );
  }

  void _addDefaultFolder(List<Folder> folders) {
    if (folders.any((folder) => folder.isDefaultFolder)) return;

    folders.insert(
      0,
      Folder(
        name: "All entries",
        isDefaultFolder: true,
        entryCount: ref.read(allEntriesProvider).requireValue.length,
      ),
    );
  }
}
