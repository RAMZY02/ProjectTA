import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:http/http.dart' as http;

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<Initial>(onInitial);
    on<LoadUser>(onLoadUser);
    on<UpdatePoin>(onUpdatePoin);
  }

  Future<void> onInitial(Initial event, Emitter<UserState> emit) async{
    emit(UserInitial());
  }

  Future<void> onLoadUser(LoadUser event, Emitter<UserState> emit) async{
    emit(UserLoaded(id: event.id, username: event.username, kelas: event.kelas.toString(), role: event.role, token: event.token, poin: event.poin, profpic: event.profpic, email: event.email, timestamps: event.timestamps));
  }
  
  Future<void> onUpdatePoin (UpdatePoin event, Emitter<UserState> emit) async{
    print("ini poin");
    print(event.poin);
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/users/poin');
    try {
      final response = await http.put(
        url, // Ganti dengan URL backend Anda
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}'
        },
        body: jsonEncode({
          'poin': event.poin,
        }),
      );

      print("ini response body");
      print(response.body);
      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        emit(UserLoaded(
          id: data['id'],
          username: data['nama'],
          kelas : data['kelas'].toString().substring(0, 1),
          role: data['role'],
          token: event.token,
          poin: data['poin'],
          profpic: data['profpic'],
          email: data['email'],
          timestamps: DateTime.parse(data['email']),
        ));
      } else {
        emit(UserError(message: 'Gagal update poin'));
      }
    } catch (e) {
      print("ini update poin");
      print(e);
      emit(UserError(message: 'Connection error: $e'));
    }
  }
}

