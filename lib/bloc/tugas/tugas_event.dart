import 'package:equatable/equatable.dart';

abstract class TugasEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TugasInit extends TugasEvent {}

class FetchTugas extends TugasEvent {
  final String token;

  FetchTugas({required this.token});

  @override
  List<Object> get props => [token];
}

class FetchTugasByKelas extends TugasEvent {
  final String token;
  final String kelas;
  final int id_user;

  FetchTugasByKelas({required this.token, required this.kelas, required this.id_user});

  @override
  List<Object> get props => [token];
}

class FetchTugasByIdUser extends TugasEvent {
  final String token;
  final int id_user;

  FetchTugasByIdUser({required this.token, required this.id_user});

  @override
  List<Object> get props => [token];
}

class CreateTugas extends TugasEvent {
  final String token;
  final int idUser;
  final int idMapel;
  final String nama;
  final String deskripsi;
  final String kelas;
  final String linkVideo;
  final String linkGambar;
  final String linkAudio;
  final String linkFile;
  final DateTime deadline;
  final int id_tahun_pelajaran;

  CreateTugas({
    required this.token,
    required this.idUser,
    required this.idMapel,
    required this.nama,
    required this.deskripsi,
    required this.kelas,
    this.linkVideo = '-',
    this.linkGambar = '-',
    this.linkAudio = '-',
    this.linkFile = '-',
    required this.deadline,
    required this.id_tahun_pelajaran,
  });

  @override
  List<Object> get props => [token, idUser, nama, deskripsi, kelas, linkVideo, linkGambar, linkAudio, linkFile, deadline];
}

class UpdateTugas extends TugasEvent {
  final String token;
  final int tugasId;
  final String nama;
  final String deskripsi;
  final String kelas;
  final String linkVideo;
  final String linkGambar;
  final String linkAudio;
  final String linkFile;
  final DateTime deadline;

  UpdateTugas({
    required this.token,
    required this.tugasId,
    required this.nama,
    required this.deskripsi,
    required this.kelas,
    this.linkVideo = '-',
    this.linkGambar = '-',
    this.linkAudio = '-',
    this.linkFile = '-',
    required this.deadline,
  });

  @override
  List<Object> get props => [token, tugasId, nama, deskripsi, kelas, linkVideo, linkGambar, linkAudio, linkFile, deadline];
}

class DeleteTugas extends TugasEvent {
  final String token;
  final int tugasId;

  DeleteTugas({
    required this.token,
    required this.tugasId,
  });

  @override
  List<Object> get props => [token, tugasId];
}