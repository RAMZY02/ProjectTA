import 'package:equatable/equatable.dart';
import 'package:project_ta/models/mata_pelajaran_model.dart';
import 'package:project_ta/models/nilai_akhir_siswa_model.dart';
import 'package:project_ta/models/nilai_akhir_wali_kelas_model.dart'; // Pastikan model sesuai

abstract class NilaiAkhirSiswaState extends Equatable {
  const NilaiAkhirSiswaState();

  @override
  List<Object?> get props => [];
}

class NilaiAkhirSiswaInitial extends NilaiAkhirSiswaState {}

class NilaiAkhirSiswaLoading extends NilaiAkhirSiswaState {}

class NilaiAkhirSiswaLoaded extends NilaiAkhirSiswaState {
  final List<NilaiAkhirSiswaModel> nilaiAkhirList;

  const NilaiAkhirSiswaLoaded(this.nilaiAkhirList);

  @override
  List<Object?> get props => [nilaiAkhirList];
}

class NilaiAkhirWaliKelasLoaded extends NilaiAkhirSiswaState {
  final List<NilaiAkhirWaliKelasModel> nilaiAkhirWaliKelasList;
  final List<MataPelajaranModel> mapelData;
  final int jumlahSiswa;
  final int jumlahSiswaIslam;
  final int jumlahSiswaHindu;
  final int jumlahSiswaKristen;
  final int jumlahSiswaKatolik;

  const NilaiAkhirWaliKelasLoaded(this.nilaiAkhirWaliKelasList, this.mapelData, this.jumlahSiswa, this.jumlahSiswaIslam, this.jumlahSiswaHindu, this.jumlahSiswaKristen, this.jumlahSiswaKatolik);

  @override
  List<Object?> get props => [nilaiAkhirWaliKelasList];
}

class NilaiAkhirSiswaDetailLoaded extends NilaiAkhirSiswaState {
  final NilaiAkhirSiswaModel nilaiAkhir;

  const NilaiAkhirSiswaDetailLoaded(this.nilaiAkhir);

  @override
  List<Object?> get props => [nilaiAkhir];
}

class NilaiAkhirSiswaCreated extends NilaiAkhirSiswaState {
  final NilaiAkhirSiswaModel nilaiAkhir;
  const NilaiAkhirSiswaCreated(this.nilaiAkhir);

  @override
  List<Object?> get props => [nilaiAkhir];
}

class NilaiAkhirSiswaUpdated extends NilaiAkhirSiswaState {
  final NilaiAkhirSiswaModel nilaiAkhir;
  const NilaiAkhirSiswaUpdated(this.nilaiAkhir);

  @override
  List<Object?> get props => [nilaiAkhir];
}

class NilaiAkhirSiswaDeleted extends NilaiAkhirSiswaState {
  final int id;
  const NilaiAkhirSiswaDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class NilaiAkhirSiswaSuccess extends NilaiAkhirSiswaState {
  final dynamic data; // response dari API
  const NilaiAkhirSiswaSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class NilaiAkhirSiswaError extends NilaiAkhirSiswaState {
  final String message;
  const NilaiAkhirSiswaError(this.message);

  @override
  List<Object?> get props => [message];
}