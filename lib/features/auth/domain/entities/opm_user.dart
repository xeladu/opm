import 'package:equatable/equatable.dart';

class OpmUser extends Equatable {
  final String id;
  final String user;

  const OpmUser({required this.id, required this.user});

  const OpmUser.empty() : this(id: "dummy", user: "dummy");

  @override
  List<Object?> get props => [id, user];
}
