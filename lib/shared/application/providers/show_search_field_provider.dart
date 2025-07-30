import 'package:flutter_riverpod/flutter_riverpod.dart';

final showSearchFieldProvider = NotifierProvider<ShowSearchFieldState, bool>(
  ShowSearchFieldState.new,
);

class ShowSearchFieldState extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setState(bool newValue) {
    state = newValue;
  }
}
