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

class FetchUsersByRoleSiswa extends UsersEvent {
  final String token;

  FetchUsersByRoleSiswa({required this.token});

  @override
  List<Object> get props => [token];
}

class FetchUsersByRoleGuru extends UsersEvent {
  final String token;

  FetchUsersByRoleGuru({required this.token});

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

class FetchUsersByKelasAndUjian extends UsersEvent {
  final String token;
  final String kelas;
  final int id_ujian;

  FetchUsersByKelasAndUjian({required this.token, required this.kelas, required this.id_ujian});

  @override
  List<Object> get props => [token, kelas];
}

class FetchUsersByTingkatan extends UsersEvent {
  final String token;
  final String kelas;

  FetchUsersByTingkatan({required this.token, required this.kelas});

  @override
  List<Object> get props => [token, kelas];
}

class FetchPengumpulanUsersByKelas extends UsersEvent {
  final int idTugas;
  final String kelas;
  final String token;

  FetchPengumpulanUsersByKelas({required this.idTugas, required this.kelas, required this.token});
}

class LoadRapot extends UsersEvent{
  final String token;
  final String kelas;
  final int id_mapel;

  LoadRapot({required this.token, required this.kelas, required this.id_mapel});
}

class AddUsers extends UsersEvent {
  final String token;
  final String nama;
  final String nis;
  final String nisn;
  final String email;
  final String password;
  final String role;
  final String nomorOrtu;
  final String kelas;
  final int id_mapel;
  final String wali_kelas;
  final int poin;
  final String profpic;
  final String keyStatus;
  final String agama;

  AddUsers({
    required this.token,
    required this.nama,
    required this.nis,
    required this.nisn,
    required this.email,
    required this.password,
    required this.role,
    this.nomorOrtu = '',
    this.kelas = '-',
    this.id_mapel = 0,
    this.wali_kelas = '-',
    this.poin = 0,
    this.profpic = '-',
    this.keyStatus = 'active',
    required this.agama,
  });

  @override
  List<Object> get props => [
    token,
    nama,
    email,
    password,
    role,
    nomorOrtu,
    kelas,
    id_mapel,
    poin,
    profpic,
    keyStatus,
  ];
}

class UpdateUsers extends UsersEvent {
  final String token;
  final int id_user;
  final String nama;
  final String nis;
  final String nisn;
  final String email;
  final String role;
  final String kelas;
  final String agama;
  final int id_mapel;
  final String wali_kelas;
  final String nomorOrtu;
  final String profpic;

  UpdateUsers({required this.token, required this.id_user, required this.nama, required this.nis, required this.nisn, required this.email, required this.role, required this.kelas, required this.agama, required this.id_mapel, required this.wali_kelas, required this.nomorOrtu, required this.profpic });

  @override
  List<Object> get props => [token, id_user, nama, email, role, kelas];
}

class UpdateUsersKelas extends UsersEvent {
  final String token;
  final int kelas;
  final List<int> notPromoted;

  UpdateUsersKelas({required this.token, required this.kelas, required this.notPromoted });

  @override
  List<Object> get props => [token, kelas, notPromoted];
}

class DeleteUsers extends UsersEvent {
  final String token;
  final int id_user;

  DeleteUsers({required this.token, required this.id_user});

  @override
  List<Object> get props => [token, id_user];
}