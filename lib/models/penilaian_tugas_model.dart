class PenilaianTugasModel {
  final int id;
  final int idUser;
  final int id_tahun_pelajaran;
  final int id_mapel;
  final String mapel;
  final String kelas;
  final int kolom;
  final int nilai;

  PenilaianTugasModel({
    required this.id,
    required this.idUser,
    required this.id_tahun_pelajaran,
    required this.id_mapel,
    required this.mapel,
    required this.kelas,
    required this.kolom,
    required this.nilai,
  });

  // Factory method untuk membuat object dari JSON
  factory PenilaianTugasModel.fromJson(Map<String, dynamic> json) {
    return PenilaianTugasModel(
      id: json['id'],
      idUser: json['id_user'],
      id_tahun_pelajaran: json['id_tahun_pelajaran'],
      id_mapel: json['id_mapel'],
      mapel: json['mapel'],
      kelas: json['kelas'],
      kolom: json['kolom'],
      nilai: json['nilai'],
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'nilai': nilai,
    };
  }

}