import 'package:project_ta/models/ujian_model.dart';

class HistoryUjianModel {
  final int id;
  final int idUjian;
  final int idUser;
  final int idTahunPelajaran;
  final String kehadiran;
  final String selesai;
  final int nilai;
  final String diperiksa;
  final DateTime timestamps;
  final UjianModel ujian;

  HistoryUjianModel({
    required this.id,
    required this.idUjian,
    required this.idUser,
    required this.idTahunPelajaran,
    required this.kehadiran,
    required this.selesai,
    required this.nilai,
    required this.diperiksa,
    required this.timestamps,
    required this.ujian,
  });

  factory HistoryUjianModel.fromJson(Map<String, dynamic> json) {
    return HistoryUjianModel(
      id: json['id'],
      idUjian: json['id_ujian'],
      idUser: json['id_user'],
      idTahunPelajaran: json['id_tahun_pelajaran'],
      kehadiran: json['kehadiran'],
      selesai: json['selesai'],
      nilai: json['nilai'],
      diperiksa: json['diperiksa'],
      timestamps: DateTime.parse(json['timpstamps']),
      ujian: UjianModel.fromJson2(json['ujian']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_ujian': idUjian,
      'id_user': idUser,
      'nilai': nilai,
      'timpstamps': timestamps.toIso8601String(),
      'ujian': ujian,
    };
  }

  @override
  String toString() {
    return 'HistoryUjian{id: $id, idUjian: $idUjian, idUser: $idUser, nilai: $nilai, timestamps: $timestamps, ujian: $ujian}';
  }
}