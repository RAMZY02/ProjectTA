class NilaiAkhirSiswaModel {
  final int id;
  final int idUser;
  final int id_mapel;
  final int id_tahun_pelajaran;
  final String mapel;
  final String kelas;
  final int nilai_akhir;
  final String capaian_kompetensi;

  NilaiAkhirSiswaModel({
    required this.id,
    required this.idUser,
    required this.id_mapel,
    required this.id_tahun_pelajaran,
    required this.mapel,
    required this.kelas,
    required this.nilai_akhir,
    required this.capaian_kompetensi,
  });

  // Factory method untuk membuat object dari JSON
  factory NilaiAkhirSiswaModel.fromJson(Map<String, dynamic> json) {
    return NilaiAkhirSiswaModel(
      id: json['id'],
      idUser: json['id_user'],
      id_mapel: json['id_mapel'],
      id_tahun_pelajaran: json['id_tahun_pelajaran'],
      mapel: json['mapel'],
      kelas: json['kelas'],
      nilai_akhir: json['nilai_akhir'],
      capaian_kompetensi: json['capaian_kompetensi'],
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
    };
  }

}