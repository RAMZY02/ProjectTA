import 'package:equatable/equatable.dart';

abstract class PenilaianTugasEvent extends Equatable {
  const PenilaianTugasEvent();

  @override
  List<Object?> get props => [];
}

// Event untuk mengambil semua penilaian tugas
class FetchAllPenilaianTugas extends PenilaianTugasEvent {
  final String token;

  const FetchAllPenilaianTugas({required this.token});

  @override
  List<Object?> get props => [token];
}

// Event untuk mengambil penilaian tugas by ID
class FetchPenilaianTugasById extends PenilaianTugasEvent {
  final int id;
  final String token;

  const FetchPenilaianTugasById({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

// Event untuk membuat penilaian tugas baru
class CreatePenilaianTugas extends PenilaianTugasEvent {
  final int idUser;
  final int id_mapel;
  final String kelas;
  final int kolom;
  final int nilai;
  final String token;

  const CreatePenilaianTugas({
    required this.idUser,
    required this.id_mapel,
    required this.kelas,
    required this.kolom,
    required this.nilai,
    required this.token,
  });

  @override
  List<Object?> get props => [idUser, nilai, token];
}

// Event untuk mengupdate penilaian tugas
class UpdatePenilaianTugas extends PenilaianTugasEvent {
  final int id;
  final int? idUser;
  final double? nilai;
  final String token;

  const UpdatePenilaianTugas({
    required this.id,
    this.idUser,
    this.nilai,
    required this.token,
  });

  @override
  List<Object?> get props => [id, idUser, nilai, token];
}

// Event untuk menghapus penilaian tugas
class DeletePenilaianTugas extends PenilaianTugasEvent {
  final int id;
  final String token;

  const DeletePenilaianTugas({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}