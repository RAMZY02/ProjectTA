import 'package:equatable/equatable.dart';

abstract class NilaiAkhirSiswaEvent extends Equatable {
  const NilaiAkhirSiswaEvent();

  @override
  List<Object?> get props => [];
}

// Event untuk mengambil semua nilai akhir siswa
class FetchAllNilaiAkhirSiswa extends NilaiAkhirSiswaEvent {
  final String token;

  const FetchAllNilaiAkhirSiswa({required this.token});

  @override
  List<Object?> get props => [token];
}

// Event untuk mengambil nilai akhir siswa by ID
class FetchNilaiAkhirSiswaById extends NilaiAkhirSiswaEvent {
  final int id;
  final String token;

  const FetchNilaiAkhirSiswaById({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

// Di nilai_akhir_siswa_event.dart
class FetchNilaiAkhirSiswaByMapelAndKelas extends NilaiAkhirSiswaEvent {
  final int id_mapel;
  final String kelas;
  final String token;

  const FetchNilaiAkhirSiswaByMapelAndKelas({
    required this.id_mapel,
    required this.kelas,
    required this.token,
  });

  @override
  List<Object?> get props => [id_mapel, kelas, token];
}

class FetchRapotWaliKelas extends NilaiAkhirSiswaEvent {
  final String kelas;
  final String token;

  const FetchRapotWaliKelas({
    required this.kelas,
    required this.token,
  });

  @override
  List<Object?> get props => [kelas, token];
}

// Event untuk membuat nilai akhir siswa baru
class CreateNilaiAkhirSiswa extends NilaiAkhirSiswaEvent {
  final int idUser;
  final String id_mapel;
  final String kelas;
  final double nilaiAkhir;
  final String capaian_kompetensi;
  final String token;

  const CreateNilaiAkhirSiswa({
    required this.idUser,
    required this.id_mapel,
    required this.kelas,
    required this.nilaiAkhir,
    required this.capaian_kompetensi,
    required this.token,
  });

  @override
  List<Object?> get props => [idUser, id_mapel, kelas, nilaiAkhir, token];
}

// Event untuk membuat/mengupdate nilai akhir siswa secara massal
class CreateAllNilaiAkhirSiswa extends NilaiAkhirSiswaEvent {
  final List<Map<String, dynamic>> nilaiAkhirList;
  final String token;

  const CreateAllNilaiAkhirSiswa({
    required this.nilaiAkhirList,
    required this.token,
  });

  @override
  List<Object?> get props => [nilaiAkhirList, token];
}

class CreateOrUpdateNilaiAkhirSiswa extends NilaiAkhirSiswaEvent {
  final int idUser;
  final int id_mapel;
  final String kelas;
  final double nilaiAkhir;
  final String capaian_kompetensi;
  final String token;

  const CreateOrUpdateNilaiAkhirSiswa({
    required this.idUser,
    required this.id_mapel,
    required this.kelas,
    required this.nilaiAkhir,
    required this.capaian_kompetensi,
    required this.token,
  });

  @override
  List<Object?> get props => [idUser, id_mapel, kelas, nilaiAkhir, token];
}

// Event untuk mengupdate nilai akhir siswa
class UpdateNilaiAkhirSiswa extends NilaiAkhirSiswaEvent {
  final int id;
  final int? idUser;
  final String? mapel;
  final String? kelas;
  final double? nilaiAkhir;
  final String? capaian_kompetensi;
  final String token;

  const UpdateNilaiAkhirSiswa({
    required this.id,
    this.idUser,
    this.mapel,
    this.kelas,
    this.nilaiAkhir,
    this.capaian_kompetensi,
    required this.token,
  });

  @override
  List<Object?> get props => [id, idUser, mapel, kelas, nilaiAkhir, token];
}

// Event untuk menghapus nilai akhir siswa
class DeleteNilaiAkhirSiswa extends NilaiAkhirSiswaEvent {
  final int id;
  final String token;

  const DeleteNilaiAkhirSiswa({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}