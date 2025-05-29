import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_handleLogin);
    on<LogoutEvent>(_handleLogout);
  }

  Future<void> _handleLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/users/login');
    try {
      final response = await http.post(
        url, // Ganti dengan URL backend Anda
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': event.email,
          'password': event.password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = responseData['data'];
        print(userData);
        emit(Authenticated(
          id: userData['id'],
          username: userData['nama'],
          kelas : userData['kelas'],
          role: userData['role'],
          token: responseData['token'],
          poin: userData['poin'],
          profpic: userData['profpic'],
          email: userData['email'],
          timestamps: DateTime.parse(userData['timestamps']),
        ));
      } else {
        emit(AuthError(responseData['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError('Connection error: $e'));
    }
  }

  void _handleLogout(LogoutEvent event, Emitter<AuthState> emit) async{
    emit(AuthInitial());
  }
}