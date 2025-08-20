import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Used by the Loading widget to display an info message
final loadingTextStateProvider = NotifierProvider<LoadingTextState, String>(LoadingTextState.new);

class LoadingTextState extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setState(String newState) {
    state = newState;
  }
}
