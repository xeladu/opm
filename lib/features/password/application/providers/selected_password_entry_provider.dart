import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/password/domain/entities/password_entry.dart';

/// Contains the currently selected password entry by the user (only relevant on desktop)
final selectedPasswordEntryProvider =
    NotifierProvider<PasswordEntryState, PasswordEntry?>(
      PasswordEntryState.new,
    );

class PasswordEntryState extends Notifier<PasswordEntry?> {
  @override
  PasswordEntry? build() {
    return null;
  }

  void setPasswordEntry(PasswordEntry? entry) {
    state = entry;
  }
}
