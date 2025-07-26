import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contains the current filter query set by the user to filter entries
final filterQueryProvider = NotifierProvider<FilterQueryState, String>(
  FilterQueryState.new,
);

class FilterQueryState extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void setQuery(String query) {
    state = query;
  }
}
