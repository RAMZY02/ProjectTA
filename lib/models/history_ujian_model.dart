import 'package:project_ta/models/ujian_model.dart';

class HistoryUjianModel {
  final int id;
  final int idUjian;
  final int idUser;
  final int nilai;
  final DateTime timestamps;
  final UjianModel ujian;

  HistoryUjianModel({
    required this.id,
    required this.idUjian,
    required this.idUser,
    required this.nilai,
    required this.timestamps,
    required this.ujian,
  });

  factory HistoryUjianModel.fromJson(Map<String, dynamic> json) {
    return HistoryUjianModel(
      id: json['id'],
      idUjian: json['id_ujian'],
      idUser: json['id_user'],
      nilai: json['nilai'],
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

  HistoryUjianModel copyWith({
    int? id,
    int? idUjian,
    int? idUser,
    int? nilai,
    DateTime? timestamps,
    UjianModel? ujian,
  }) {
    return HistoryUjianModel(
      id: id ?? this.id,
      idUjian: idUjian ?? this.idUjian,
      idUser: idUser ?? this.idUser,
      nilai: nilai ?? this.nilai,
      timestamps: timestamps ?? this.timestamps,
      ujian: ujian ?? this.ujian,
    );
  }

  @override
  String toString() {
    return 'HistoryUjian{id: $id, idUjian: $idUjian, idUser: $idUser, nilai: $nilai, timestamps: $timestamps, ujian: $ujian}';
  }
}