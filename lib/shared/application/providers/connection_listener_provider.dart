import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/application/providers/no_connection_provider.dart';

/// Starts a platform connectivity listener and writes a boolean state into
/// `noConnectionProvider` whenever connectivity changes. This provider does
/// not itself emit values for consumers; it only runs the side-effect listener.
final connectionListenerProvider = Provider.autoDispose<void>((ref) {
  final provider = ref.read(noConnectionProvider.notifier);
  final connectivity = Connectivity();

  // Emit initial state
  connectivity
      .checkConnectivity()
      .then((initial) {
        provider.setConnectionState(
          initial.length == 1 && initial.first == ConnectivityResult.none,
        );
      })
      .catchError((_) {
        provider.setConnectionState(true);
      });

  // Forward subsequent connectivity changes
  final sub = connectivity.onConnectivityChanged.listen((result) {
    provider.setConnectionState(result.length == 1 && result.first == ConnectivityResult.none);
  });

  ref.onDispose(() {
    sub.cancel();
  });
});
