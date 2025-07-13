import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Init extends UsersEvent {}

class FetchUsers extends UsersEvent {
  String token;

  FetchUsers({required this.token});

  @override
  List<Object> get props => [token];
}

class FetchUsersByKelas extends UsersEvent {
  String token;
  String kelas;

  FetchUsersByKelas({required this.token, required this.kelas});

  @override
  List<Object> get props => [token, kelas];
}

class AddUsers extends UsersEvent {
  String token;
  String nama;
  String email;
  String password;
  String role;
  String kelas;

  AddUsers({required this.token, required this.nama, required this.email, required this.password, required this.role, required this.kelas });

  @override
  List<Object> get props => [token, nama, email, password, role, kelas];
}

class UpdateUsers extends UsersEvent {
  String token;
  int id_user;
  String nama;
  String email;
  String role;
  String kelas;

  UpdateUsers({required this.token, required this.id_user, required this.nama, required this.email, required this.role, required this.kelas });

  @override
  List<Object> get props => [token, id_user, nama, email, role, kelas];
}

class DeleteUsers extends UsersEvent {
  String token;
  int id_user;

  DeleteUsers({required this.token, required this.id_user});

  @override
  List<Object> get props => [token, id_user];
}