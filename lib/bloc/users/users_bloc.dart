import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/models/user_model.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersInitial()) {
    on<Init>(_onInit);
    on<FetchUsers>(_onFetchUsers);
    on<FetchUsersByKelas>(_onFetchUsersByKelas);
    on<AddUsers>(_onAddUsers);
    on<UpdateUsers>(_onUpdateUsers);
    on<DeleteUsers>(_onDeleteUsers);
  }

  Future<void> _onInit(Init event, Emitter<UsersState> emit) async {
    emit(UsersInitial());
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        'https://flounder-moved-rooster.ngrok-free.app/api/users');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print("ini users");
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final users = data.map((user) => UserModel.fromJson(user)).toList();
        print(users);
        emit(UsersLoaded(users: users));
      } else {
        emit(UsersError(message: 'Failed to load users'));
      }
    } catch (e) {
      print(e);
      emit(UsersError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchUsersByKelas(FetchUsersByKelas event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        'https://flounder-moved-rooster.ngrok-free.app/api/users/kelas/${event.kelas}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print("ini users");
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final users = data.map((user) => UserModel.fromJson(user)).toList();
        print(users);
        emit(UsersLoaded(users: users));
      } else {
        emit(UsersError(message: 'Failed to load users'));
      }
    } catch (e) {
      print(e);
      emit(UsersError(message: 'Error: $e'));
    }
  }

  Future<void> _onAddUsers(AddUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        'https://flounder-moved-rooster.ngrok-free.app/api/users');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'email' : event.email,
          'password' : event.password,
          'nama' : event.nama,
          'role' : event.role,
          'kelas' : event.kelas
        })
      );

      print("ini add users");
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        add(FetchUsers(token: event.token));
      } else {
        emit(UsersError(message: 'Failed to load users'));
      }
    } catch (e) {
      print(e);
      emit(UsersError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateUsers(UpdateUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        'https://flounder-moved-rooster.ngrok-free.app/api/users/${event.id_user}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'email' : event.email,
            'nama' : event.nama,
            'role' : event.role,
            'kelas' : event.kelas
          })
      );

      print("ini update users");
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        add(FetchUsers(token: event.token));
      } else {
        emit(UsersError(message: 'Failed to load users'));
      }
    } catch (e) {
      print(e);
      emit(UsersError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteUsers(DeleteUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        'https://flounder-moved-rooster.ngrok-free.app/api/users/delete/${event.id_user}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
      );

      print("ini delete users");
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        add(FetchUsers(token: event.token));
      } else {
        emit(UsersError(message: 'Failed to load users'));
      }
    } catch (e) {
      print(e);
      emit(UsersError(message: 'Error: $e'));
    }
  }
}