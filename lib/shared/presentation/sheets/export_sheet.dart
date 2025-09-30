import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/application/use_cases/export_vault.dart';
import 'package:open_password_manager/shared/presentation/loading.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExportSheet extends StatefulWidget {
  final Future<bool> Function(ExportOption) onSelected;

  const ExportSheet({super.key, required this.onSelected});

  @override
  State<ExportSheet> createState() => _State();
}

class _State extends State<ExportSheet> {
  ExportOption _selectedOption = ExportOption.json;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Sheet(
      preventDismiss: _exporting,
      title: "Choose Export Format",
      description:
          "You are about to export your entire vault to a cleartext file. Do not share it via email or on social media. Make sure to delete it properly as soon as possible!\n\nPlease select your desired export format and confirm.",
      primaryButtonCaption: "Export",
      content: Column(
        spacing: sizeXS,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadCard(
            child: Row(
              spacing: sizeXS,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(LucideIcons.triangleAlert, color: Colors.orange, size: sizeL),
                Expanded(
                  child: Text(
                    "Choose JSON to get a full export. CSV export is limited to credential entries!",
                  ),
                ),
              ],
            ),
          ),
          ShadSelect<ExportOption>(
            enabled: !_exporting,
            maxWidth: selectSmallWidth,
            minWidth: selectSmallWidth,
            initialValue: ExportOption.json,
            selectedOptionBuilder: (context, selection) => Text(selection.name.toUpperCase()),
            options: ExportOption.values.map(
              (entry) => ShadOption(value: entry, child: Text(entry.name.toUpperCase())),
            ),
            onChanged: (option) {
              setState(() {
                _selectedOption = option!;
              });
            },
          ),
          if (_exporting) Loading(text: "Export is running. Please wait!"),
        ],
      ),
      onPrimaryButtonPressed: () async {
        try {
          setState(() {
            _exporting = true;
          });

          final success = await widget.onSelected(_selectedOption);
          return success;
        } finally {
          setState(() {
            _exporting = false;
          });
        }
      },
    );
  }
}
