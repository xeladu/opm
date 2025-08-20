import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Used by the Loading widget to display the progress. A null value means the progress is indefinite.
final loadingValueStateProvider = NotifierProvider<LoadingValueState, double?>(
  LoadingValueState.new,
);

class LoadingValueState extends Notifier<double?> {
  @override
  double? build() {
    return null;
  }

  void setState(double? newState) {
    state = newState;
  }
}
