import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/application/use_cases/import_vault.dart';
import 'package:open_password_manager/shared/application/providers/file_picker_service_provider.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/shared/presentation/buttons/primary_button.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/shared/utils/toast_service.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ImportSheet extends ConsumerStatefulWidget {
  final Function(ImportProvider, String) onSelected;

  const ImportSheet({super.key, required this.onSelected});

  @override
  ConsumerState<ImportSheet> createState() => _State();
}

class _State extends ConsumerState<ImportSheet> {
  ImportProvider _selectedProvider = ImportProvider.opm;
  String _filePath = "";
  String _fileContent = "";

  @override
  Widget build(BuildContext context) {
    return Sheet(
      title: "Import Data",
      description:
          "You can import data from other password manager tools or an OPM backup here. Create a CSV export from the current password manager and select it here. The importer will convert the data and add all entries to your OPM vault.\n\n"
          "Your existing entries won't be touched!",
      primaryButtonCaption: "Import",
      content: Column(
        spacing: sizeXS,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sizeXXS),
          Text(
            "Select CSV file",
            style: ShadTheme.of(context).textTheme.small,
            textAlign: TextAlign.left,
          ),
          Row(
            spacing: sizeXS,
            children: [
              PrimaryButton(caption: "Pick CSV file", onPressed: _pickFile),
              if (_filePath.isNotEmpty)
                GlyphButton.important(
                  onTap: () {
                    setState(() {
                      _filePath = "";
                      _fileContent = "";
                    });
                  },
                  icon: LucideIcons.trash,
                ),
            ],
          ),
          Text(
            _filePath.isEmpty ? " - no file selected - " : _filePath,
            style: ShadTheme.of(context).textTheme.muted,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: sizeXXS),
          Text(
            "Select provider",
            style: ShadTheme.of(context).textTheme.small,
            textAlign: TextAlign.left,
          ),
          ShadSelect<ImportProvider>(
            maxWidth: selectLargeWidth,
            minWidth: selectLargeWidth,
            initialValue: ImportProvider.opm,
            selectedOptionBuilder: (context, selection) => Text(selection.title),
            options: ImportProvider.values.map(
              (entry) => ShadOption(value: entry, child: Text(entry.title)),
            ),
            onChanged: (option) {
              setState(() {
                _selectedProvider = option!;
              });
            },
          ),
        ],
      ),
      onPrimaryButtonPressed: () async {
        if (_filePath.isEmpty) {
          ToastService.showError(context, "Please select a file first!");
          return false;
        }

        widget.onSelected(_selectedProvider, _fileContent);
        return true;
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await ref.read(filePickerServiceProvider).pickFile();

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final content = String.fromCharCodes(file.bytes!);

    setState(() {
      _filePath = file.path ?? "";
      _fileContent = content;
    });
  }
}
