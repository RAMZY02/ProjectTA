import 'package:project_ta/models/hadiah_model.dart';

class KuponModel {
  final int id;
  final int idHadiah;
  final String kode;
  final String tipe;
  final DateTime waktu;
  final DateTime kadaluarsa;
  final String status;
  final HadiahModel hadiah;

  KuponModel({
    required this.id,
    required this.idHadiah,
    required this.kode,
    required this.tipe,
    required this.waktu,
    required this.kadaluarsa,
    required this.status,
    required this.hadiah,
  });

  factory KuponModel.fromJson(Map<String, dynamic> json) {
    return KuponModel(
      id: json['id'],
      idHadiah: json['id_hadiah'],
      kode: json['kode'],
      tipe: json['tipe'],
      waktu: DateTime.parse(json['waktu']),
      kadaluarsa: DateTime.parse(json['kadaluarsa']),
      status: json['status'],
      hadiah: HadiahModel.fromJson(json['hadiah']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_hadiah': idHadiah,
      'kode': kode,
      'tipe': tipe,
      'waktu': waktu.toIso8601String(),
      'kadaluarsa': kadaluarsa.toIso8601String(),
      'status': status,
      'hadiah': hadiah,
    };
  }
}