import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/vault/domain/entities/vault_entry.dart';

/// Contains the currently selected entry by the user (only relevant on desktop)
final selectedEntryProvider = NotifierProvider<SelectedEntryState, VaultEntry?>(
  SelectedEntryState.new,
);

class SelectedEntryState extends Notifier<VaultEntry?> {
  @override
  VaultEntry? build() {
    return null;
  }

  void setEntry(VaultEntry? entry) {
    state = entry;
  }
}
