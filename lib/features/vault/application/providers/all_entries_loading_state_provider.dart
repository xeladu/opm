import 'package:flutter_riverpod/flutter_riverpod.dart';

final allEntriesLoadingStateProvider = NotifierProvider<AllEntriesLoadingState, String?>(
  AllEntriesLoadingState.new,
);

class AllEntriesLoadingState extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setState(String newState) {
    state = newState;
  }
}
