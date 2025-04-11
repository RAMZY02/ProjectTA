import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      // emit(AuthLoading());
      // await Future.delayed(const Duration(seconds: 2)); // Simulasi API call
      if (event.email == "admin" && event.password == "123") {
        emit(Authenticated("Admin"));
      } else {
        emit(AuthError("Login gagal! Cek email dan password."));
      }
    });

    on<LogoutEvent>((event, emit) {
      emit(AuthInitial());
    });
  }
}
