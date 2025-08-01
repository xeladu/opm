import 'package:open_password_manager/features/vault/application/providers/filter_query_provider.dart';

class FakeFilterQueryState extends FilterQueryState {
  final String query;
  FakeFilterQueryState(this.query);

  @override
  String build() {
    return query;
  }
}
