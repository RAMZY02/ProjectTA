import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Init extends UsersEvent {}

class FetchUsers extends UsersEvent {
  final String token;

  FetchUsers({required this.token});

  @override
  List<Object> get props => [token];
}

class FetchUsersByKelas extends UsersEvent {
  final String token;
  final String kelas;

  FetchUsersByKelas({required this.token, required this.kelas});

  @override
  List<Object> get props => [token, kelas];
}

class LoadRapot extends UsersEvent{
  final String token;
  final String kelas;
  final String mapel;

  LoadRapot({required this.token, required this.kelas, required this.mapel});
}

class AddUsers extends UsersEvent {
  final String token;
  final String nama;
  final String email;
  final String password;
  final String role;
  final String kelas;

  AddUsers({required this.token, required this.nama, required this.email, required this.password, required this.role, required this.kelas });

  @override
  List<Object> get props => [token, nama, email, password, role, kelas];
}

class UpdateUsers extends UsersEvent {
  final String token;
  final int id_user;
  final String nama;
  final String email;
  final String role;
  final String kelas;

  UpdateUsers({required this.token, required this.id_user, required this.nama, required this.email, required this.role, required this.kelas });

  @override
  List<Object> get props => [token, id_user, nama, email, role, kelas];
}

class DeleteUsers extends UsersEvent {
  final String token;
  final int id_user;

  DeleteUsers({required this.token, required this.id_user});

  @override
  List<Object> get props => [token, id_user];
}