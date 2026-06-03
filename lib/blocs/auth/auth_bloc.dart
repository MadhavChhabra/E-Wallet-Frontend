import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_ewallet/blocs/auth/auth_event.dart';
import 'package:flutter_ewallet/blocs/auth/auth_state.dart';
import 'package:flutter_ewallet/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
  //  if (event is AuthRegister) {
  //     yield AuthLoading();
  //     try {
  //       final user = await AuthService.register(event.data.toJson());
  //       yield AuthSuccess(user);
  //     } catch (e) {
  //       yield AuthFailed('Failed to register: $e');
  //     }
  //   } else if (event is AuthLogin) {
  //     yield AuthLoading();
  //     try {
  //       final userData = await AuthService.login(event.credentials as Map<String, dynamic>);
  //       yield AuthSuccess(UserModel.formJson(userData['data']));
  //     } catch (e) {
  //       yield AuthFailed('Failed to login: $e');
  //     }
  //   }
  }
}
