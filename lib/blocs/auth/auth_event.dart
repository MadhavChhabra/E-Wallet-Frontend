import 'package:equatable/equatable.dart';
import 'package:flutter_ewallet/models/sign_up_model.dart';
import 'package:flutter_ewallet/models/user_model.dart'; // Assuming you have a model for user credentials

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckEmail extends AuthEvent {
  final String email;

  const AuthCheckEmail(this.email);

  @override
  List<Object> get props => [email];
}

class AuthRegister extends AuthEvent {
  final SignUpModel data;

  const AuthRegister(this.data);

  @override
  List<Object> get props => [data];
}

class AuthLogin extends AuthEvent {
  final UserModel credentials;

  const AuthLogin(this.credentials);

  @override
  List<Object> get props => [credentials];
}
