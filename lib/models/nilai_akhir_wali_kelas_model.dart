class NilaiAkhirWaliKelasModel {
  final int idMapel;
  final String mapel;
  final int jumlahTerkirim;

  NilaiAkhirWaliKelasModel({
    required this.idMapel,
    required this.mapel,
    required this.jumlahTerkirim,
  });

  // Factory method untuk membuat object dari JSON
  factory NilaiAkhirWaliKelasModel.fromJson(Map<String, dynamic> json) {
    return NilaiAkhirWaliKelasModel(
      idMapel: json['id_mapel'],
      mapel: json['mapel'],
      jumlahTerkirim: json['jumlah_terkirim'],
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id_mapel': idMapel,
      'mapel': mapel,
      'jumlah_terkirim': jumlahTerkirim,
    };
  }
}