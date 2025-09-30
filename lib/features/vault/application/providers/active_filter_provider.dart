import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/shared/domain/entities/filter.dart';

/// Contains the current filter selected by the user
final activeFilterProvider = NotifierProvider<ActiveFilterState, Filter?>(ActiveFilterState.new);

class ActiveFilterState extends Notifier<Filter?> {
  @override
  Filter? build() {
    return null;
  }

  void setFolder(Filter? filter) {
    state = filter;
  }
}
