import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/models/user_model.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {

  // final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  UsersBloc() : super(UsersInitial()) {
    on<Init>(_onInit);
    on<FetchUsers>(_onFetchUsers);
    on<FetchUsersByRoleSiswa>(_onFetchUsersByRoleSiswa);
    on<FetchUsersByRoleGuru>(_onFetchUsersByRoleGuru);
    on<FetchUsersByKelas>(_onFetchUsersByKelas);
    on<FetchUsersByKelasAndUjian>(_onFetchUsersByKelasAndUjian);
    on<FetchUsersByTingkatan>(_onFetchUsersByTingkatan);
    on<FetchPengumpulanUsersByKelas>(_onFetchPengumpulanUsersByKelas);
    on<LoadRapot>(_onLoadRapot);
    on<AddUsers>(_onAddUsers);
    on<UpdateUsers>(_onUpdateUsers);
    on<UpdateUsersKelas>(_onUpdateUsersKelas);
    on<DeleteUsers>(_onDeleteUsers);
  }

  Future<void> _onInit(Init event, Emitter<UsersState> emit) async {
    emit(UsersInitial());
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse('$baseUrl/api/users');
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

  Future<void> _onFetchUsersByRoleSiswa(FetchUsersByRoleSiswa event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/role/siswa');
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

  Future<void> _onFetchUsersByRoleGuru(FetchUsersByRoleGuru event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/role/guru');
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
        '$baseUrl/api/users/kelas/${event.kelas}');
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

  Future<void> _onFetchUsersByKelasAndUjian(FetchUsersByKelasAndUjian event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/kelas/${event.kelas}/${event.id_ujian}');
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

  Future<void> _onFetchUsersByTingkatan(FetchUsersByTingkatan event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/tingkatan/${event.kelas}');
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

  Future<void> _onFetchPengumpulanUsersByKelas(FetchPengumpulanUsersByKelas event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final url = Uri.parse("$baseUrl/api/users/pengumpulan/${event.kelas}/${event.idTugas}");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${event.token}',
      });

      final List<dynamic> data = json.decode(response.body);
      print("ini data nya");
      print(data);

      if (response.statusCode == 200) {
        final pengumpulTugas = data.map((pengumpul) => UserModel.fromJson(pengumpul)).toList();
        emit(UsersLoaded(users: pengumpulTugas));
      } else {
        emit(UsersError(message:  "Failed load pengumpulan"));
      }
    } catch (e) {
      emit(UsersError(message: "Error: $e"));
    }
  }

  Future<void> _onLoadRapot(LoadRapot event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/rapot/${event.kelas}/${event.id_mapel}');
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
        '$baseUrl/api/users');
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'email': event.email,
            'password': event.password,
            'nama': event.nama,
            'nis': event.nis,
            'nisn': event.nisn,
            'role': event.role,
            'nomor_ortu': event.nomorOrtu,
            'kelas': event.kelas,
            'agama': event.agama,
            'id_mapel': event.id_mapel,
            'wali_kelas': event.wali_kelas,
            'poin': event.poin,
            'profpic': event.profpic,
            'key_status': event.keyStatus,
          })
      );

      print("ini add users");
      print(response.body);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(responseData);

        add(FetchUsers(token: event.token));
      } else {
        // Handle error response
        final errorData = json.decode(response.body);
        emit(UsersError(message: 'Failed to add user: ${errorData['message'] ?? 'Unknown error'}'));
      }
    } catch (e) {
      print(e);
      emit(UsersError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateUsers(UpdateUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/${event.id_user}');
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
            'nis' : event.nis,
            'nisn' : event.nisn,
            'role' : event.role,
            'kelas' : event.kelas,
            'agama' : event.agama,
            'id_mapel' : event.id_mapel,
            'wali_kelas' : event.wali_kelas,
            'nomor_ortu' : event.nomorOrtu,
            'profpic' : event.profpic
          })
      );

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

  Future<void> _onUpdateUsersKelas(UpdateUsersKelas event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final url = Uri.parse(
        '$baseUrl/api/users/kelas/${event.kelas}/${event.notPromoted}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          }
      );

      if (response.statusCode == 200) {
        print("masuk sini gasih ini");
        add(FetchUsersByTingkatan(token: event.token, kelas: event.kelas.toString()));
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
        '$baseUrl/api/users/delete/${event.id_user}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
      );

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