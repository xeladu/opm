import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contains the current filter query set by the user to filter password entries
final passwordFilterQueryProvider =
    NotifierProvider<PasswordFilterQueryState, String>(
      PasswordFilterQueryState.new,
    );

class PasswordFilterQueryState extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setQuery(String query) {
    state = query;
  }
}
