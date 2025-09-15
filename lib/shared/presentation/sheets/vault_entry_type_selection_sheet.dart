import 'package:flutter/material.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry_type.dart';
import 'package:open_password_manager/shared/presentation/buttons/secondary_button.dart';
import 'package:open_password_manager/shared/presentation/sheet.dart';
import 'package:open_password_manager/style/ui.dart';

class VaultEntryTypeSelectionSheet extends StatefulWidget {
  final void Function(VaultEntryType) onSelected;

  const VaultEntryTypeSelectionSheet({super.key, required this.onSelected});

  @override
  State<VaultEntryTypeSelectionSheet> createState() => _State();
}

class _State extends State<VaultEntryTypeSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return Sheet(
      title: "Choose entry type",
      description:
          "What type of entry do you want to store? We prepare the correct input fields for your choice.",
      primaryButtonCaption: "Cancel",
      hideSecondaryButton: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: VaultEntryType.values
            .map(
              (t) => Padding(
                padding: EdgeInsets.symmetric(vertical: sizeXS),
                child: SecondaryButton(
                  icon: t.toIcon(),
                  caption: t.toNiceString(),
                  onPressed: () async {
                    widget.onSelected(t);

                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
