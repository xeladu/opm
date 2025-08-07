import 'package:equatable/equatable.dart';

class Credentials extends Equatable {
  final String email;
  final String password;

  const Credentials({required this.email, required this.password});

  const Credentials.empty() : this(email: "", password: "");

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  factory Credentials.fromJson(Map<String, dynamic> json) => Credentials(
    email: json['email'] as String,
    password: json['password'] as String,
  );

  @override
  List<Object?> get props => [email, password];
}
