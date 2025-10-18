import 'package:equatable/equatable.dart';

abstract class PengumpulanTugasEvent extends Equatable {
  const PengumpulanTugasEvent();

  @override
  List<Object?> get props => [];
}

// Event untuk mengambil semua pengumpulan berdasarkan user/tugas
class FetchPengumpulanTugas extends PengumpulanTugasEvent {
  final int idUser;
  final int idTugas;
  final String token;

  const FetchPengumpulanTugas({
    required this.idUser,
    required this.idTugas,
    required this.token,
  });

  @override
  List<Object?> get props => [idUser, idTugas, token];
}

class FetchPengumpulanByTugas extends PengumpulanTugasEvent {
  final int idTugas;
  final String token;

  const FetchPengumpulanByTugas({required this.idTugas, required this.token});
}

class SubmitPengumpulanTugas extends PengumpulanTugasEvent {
  final int idUser;
  final int idTugas;
  final String deskripsi;
  final String token;
  final String? gambarPath;
  final String? videoPath;
  final String? audioPath;
  final String? filePath;

  const SubmitPengumpulanTugas({
    required this.idUser,
    required this.idTugas,
    required this.deskripsi,
    required this.token,
    this.gambarPath,
    this.videoPath,
    this.audioPath,
    this.filePath,
  });

  @override
  List<Object?> get props => [
    idUser,
    idTugas,
    deskripsi,
    token,
    gambarPath,
    videoPath,
    audioPath,
    filePath
  ];
}

class UpdatePengumpulanNilai extends PengumpulanTugasEvent {
  final int id;
  final String token;
  final int nilai;

  const UpdatePengumpulanNilai({required this.id, required this.token, required this.nilai});
}

