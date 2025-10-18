import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final int id;
  final String username;
  final String kelas;
  final String agama;
  final int id_mapel;
  final String mapel;
  final String wali_kelas;
  final String role;
  final String nomor_ortu;
  final String token;
  final int poin;
  final String profpic;
  final String email;
  final DateTime timestamps;

  Authenticated({
    required this.id,
    required this.username,
    required this.kelas,
    required this.agama,
    required this.id_mapel,
    required this.mapel,
    required this.wali_kelas,
    required this.role,
    required this.nomor_ortu,
    required this.token,
    required this.poin,
    required this.profpic,
    required this.email,
    required this.timestamps
  });

  @override
  List<Object> get props => [id, username, kelas, agama, id_mapel, wali_kelas, role, nomor_ortu, token, poin, profpic, email, timestamps];
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}