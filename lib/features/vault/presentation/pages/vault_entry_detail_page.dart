import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/edit_entry_button.dart';
import 'package:open_password_manager/features/vault/presentation/widgets/vault_entry_details.dart';
import 'package:open_password_manager/shared/presentation/responsive_app_frame.dart';
import 'package:open_password_manager/style/ui.dart';

class VaultEntryDetailPage extends ConsumerWidget {
  final VaultEntry entry;
  const VaultEntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveAppFrame(
      title: entry.name,
      content: Padding(
        padding: const EdgeInsets.all(sizeS),
        child: VaultEntryDetails(entry: entry),
      ),
      mobileButton: EditEntryButton(entry: entry),
      hideSearchButton: true,
      hideFolderButton: true,
    );
  }
}
