import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_password_manager/features/auth/domain/entities/opm_user.dart';

final opmUserProvider = NotifierProvider<OpmUserState, OpmUser>(
  OpmUserState.new,
);

class OpmUserState extends Notifier<OpmUser> {
  @override
  OpmUser build() {
    return OpmUser.empty();
  }

  void setUser(OpmUser user) {
    state = user;
  }
}
