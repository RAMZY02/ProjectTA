import 'package:equatable/equatable.dart';

abstract class MataPelajaranEvent extends Equatable {
  const MataPelajaranEvent();

  @override
  List<Object?> get props => [];
}

class InitialMataPelajaran extends MataPelajaranEvent{}

// Event untuk mengambil semua mata pelajaran aktif
class FetchAllMataPelajaran extends MataPelajaranEvent {
  final String token;

  const FetchAllMataPelajaran({required this.token});

  @override
  List<Object?> get props => [token];
}

// Event untuk mengambil mata pelajaran by ID
class FetchMataPelajaranById extends MataPelajaranEvent {
  final int id;
  final String token;

  const FetchMataPelajaranById({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

class FetchMataPelajaranSiswa extends MataPelajaranEvent {
  final int id_user;
  final String token;

  const FetchMataPelajaranSiswa({required this.id_user, required this.token});

  @override
  List<Object?> get props => [id_user, token];
}

// Event untuk membuat mata pelajaran baru
class CreateMataPelajaran extends MataPelajaranEvent {
  final String mapel;
  final String token;

  const CreateMataPelajaran({
    required this.mapel,
    required this.token,
  });

  @override
  List<Object?> get props => [mapel, token];
}

// Event untuk mengupdate mata pelajaran
class UpdateMataPelajaran extends MataPelajaranEvent {
  final int id;
  final String? mapel;
  final String? keyStatus;
  final String token;

  const UpdateMataPelajaran({
    required this.id,
    this.mapel,
    this.keyStatus,
    required this.token,
  });

  @override
  List<Object?> get props => [id, mapel, keyStatus, token];
}

// Event untuk menghapus mata pelajaran (soft delete)
class DeleteMataPelajaran extends MataPelajaranEvent {
  final int id;
  final String token;

  const DeleteMataPelajaran({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

// Event untuk mengembalikan mata pelajaran yang dihapus
class RestoreMataPelajaran extends MataPelajaranEvent {
  final int id;
  final String token;

  const RestoreMataPelajaran({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}