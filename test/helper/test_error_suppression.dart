import 'package:flutter/foundation.dart';

/// Suppresses Flutter's render overflow errors during widget tests. Must be called in every test. Does not work in setup methods!
void suppressOverflowErrors() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }

    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };
}
