import 'package:bloc/bloc.dart';
import 'package:flutter_ewallet/blocs/auth/auth_event.dart';
import 'package:flutter_ewallet/blocs/auth/auth_state.dart';
import 'package:flutter_ewallet/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial());
}
