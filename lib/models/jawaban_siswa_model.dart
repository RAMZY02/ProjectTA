class JawabanSiswaModel {
  final int id;
  final int idUjian;
  final int idUser;
  final int idSoal;
  final int urutan;
  final String jawaban;
  final int nilai;

  JawabanSiswaModel({
    required this.id,
    required this.idUjian,
    required this.idUser,
    required this.idSoal,
    required this.urutan,
    required this.jawaban,
    required this.nilai,
  });

  factory JawabanSiswaModel.fromJson(Map<String, dynamic> json) {
    return JawabanSiswaModel(
      id: json['id'],
      idUjian: json['id_ujian'],
      idUser: json['id_user'],
      idSoal: json['id_soal'],
      urutan: json['urutan'],
      jawaban: json['jawaban'],
      nilai: json['nilai'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_ujian': idUjian,
      'id_user': idUser,
      'id_soal': idSoal,
      'urutan': urutan,
      'jawaban': jawaban,
      'nilai': nilai,
    };
  }
}