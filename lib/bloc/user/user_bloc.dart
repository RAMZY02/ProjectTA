import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:http/http.dart' as http;

class UserBloc extends Bloc<UserEvent, UserState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';

  UserBloc() : super(UserInitial()) {
    on<Initial>(onInitial);
    on<LoadUser>(onLoadUser);
    on<UpdatePoin>(onUpdatePoin);
    on<UpdateProfpic>(onUpdateProfpic);
    on<ChangePassword>(onChangePassword);
  }

  Future<void> onInitial(Initial event, Emitter<UserState> emit) async{
    emit(UserInitial());
  }

  Future<void> onLoadUser(LoadUser event, Emitter<UserState> emit) async{
    emit(UserLoaded(id: event.id, username: event.username, kelas: event.kelas.toString(), agama: event.agama, role: event.role, nomor_ortu: event.nomor_ortu, id_mapel: event.id_mapel, mapel: event.mapel, token: event.token, poin: event.poin, profpic: event.profpic, email: event.email));
  }
  
  Future<void> onUpdatePoin (UpdatePoin event, Emitter<UserState> emit) async{
    print("ini poin");
    print(event.poin);
    final url = Uri.parse('$baseUrl/api/users/poin');
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

      print("ini response body user poin");
      print(response.body);
      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        emit(UserLoaded(
          id: data['id'],
          username: data['nama'],
          kelas : data['kelas'].toString().substring(0, 1),
          agama: data['agama'],
          role: data['role'],
          id_mapel: data['id_mapel'],
          mapel: data['mapel'],
          nomor_ortu: data['nomor_ortu'],
          token: event.token,
          poin: data['poin'],
          profpic: data['profpic'],
          email: data['email'],
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

  Future<void> onUpdateProfpic (UpdateProfpic event, Emitter<UserState> emit) async {
    final url = Uri.parse('$baseUrl/api/users/profpic');
    try {
      final response = await http.put(
        url, // Ganti dengan URL backend Anda
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}'
        },
        body: jsonEncode({
          'profpic': event.profpic,
        }),
      );

      print("ini response body user profpic");
      print(response.body);
      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        emit(UserLoaded(
          id: data['id'],
          username: data['nama'],
          kelas : data['kelas'].toString().substring(0, 1),
          agama: data['agama'],
          role: data['role'],
          id_mapel: data['id_mapel'],
          mapel: data['mapel'],
          nomor_ortu: data['nomor_ortu'],
          token: event.token,
          poin: data['poin'],
          profpic: data['profpic'],
          email: data['email'],
        ));
      } else {
        emit(UserError(message: 'Gagal update profpic'));
      }
    } catch (e) {
      print("ini update profpic");
      print(e);
      emit(UserError(message: 'Connection error: $e'));
    }
  }

  Future<void> onChangePassword (ChangePassword event, Emitter<UserState> emit) async {
    final url = Uri.parse('$baseUrl/api/users/change-password');
    try {
      final response = await http.put(
        url, // Ganti dengan URL backend Anda
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}'
        },
        body: jsonEncode({
          'currentPassword': event.currentPassword,
          'newPassword': event.newPassword,
        }),
      );

      print("ini response body user ganti password");
      print(response.body);
      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        emit(UserLoaded(
          id: data['id'],
          username: data['nama'],
          kelas : data['kelas'].toString().substring(0, 1),
          agama: data['agama'],
          role: data['role'],
          id_mapel: data['id_mapel'],
          mapel: data['mapel'],
          nomor_ortu: data['nomor_ortu'],
          token: event.token,
          poin: data['poin'],
          profpic: data['profpic'],
          email: data['email'],
        ));
      } else {
        emit(UserError(message: 'Gagal ganti password'));
      }
    } catch (e) {
      print("ini ganti password");
      print(e);
      emit(UserError(message: 'Connection error: $e'));
    }
  }
}

