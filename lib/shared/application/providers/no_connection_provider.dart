import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indicates if there is no network connection (wifi, cellular)
final noConnectionProvider = NotifierProvider<NoConnectionState, bool>(NoConnectionState.new);

class NoConnectionState extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setConnectionState(bool newConnectionState) {
    state = newConnectionState;
  }
}
