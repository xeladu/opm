import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indicates if an add/edit form is open or not
final addEditModeActiveProvider =
    NotifierProvider<AddEditModeActiveState, bool>(AddEditModeActiveState.new);

class AddEditModeActiveState extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setMode(bool enabled) {
    state = enabled;
  }
}
