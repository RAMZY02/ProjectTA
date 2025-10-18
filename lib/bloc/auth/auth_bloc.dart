import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_handleLogin);
    on<LogoutEvent>(_handleLogout);
  }

  Future<void> _handleLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final url = Uri.parse('$baseUrl/api/users/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': event.email,
          'password': event.password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = responseData['data'];
        print('ini user di bloc');
        print(userData);

        // Parse timestamps dari string ke DateTime
        DateTime timestamps;
        try {
          timestamps = DateTime.parse(userData['timestamps']);
        } catch (e) {
          timestamps = DateTime.now();
        }

        emit(Authenticated(
          id: userData['id'],
          username: userData['nama'],
          kelas: userData['kelas'] ?? '',
          agama: userData['agama'] ?? '',
          id_mapel: userData['id_mapel'] ?? '',
          mapel: userData['mapel'] ?? '',
          wali_kelas: userData['wali_kelas'] ?? '',
          role: userData['role'],
          nomor_ortu: userData['nomor_ortu'] ?? '',
          token: responseData['token'] ?? '',
          poin: userData['poin'] ?? 0,
          profpic: userData['profpic'] ?? '',
          email: userData['email'],
          timestamps: timestamps,
        ));
      } else {
        emit(AuthError(responseData['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError('Connection error: $e'));
    }
  }

  void _handleLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}