import 'package:flutter_riverpod/flutter_riverpod.dart';

final hasChangesProvider = NotifierProvider<HasChangesState, bool>(
  HasChangesState.new,
);

class HasChangesState extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setHasChanges(bool value) {
    state = value;
  }
}
