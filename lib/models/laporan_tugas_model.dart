class LaporanTugasModel {
  final int id;
  final String nama;
  final int nilai;

  LaporanTugasModel({
    required this.id,
    required this.nama,
    required this.nilai,
  });

  factory LaporanTugasModel.fromJson(Map<String, dynamic> json) {
    return LaporanTugasModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      nilai: json['nilai'] is int ? json['nilai'] : int.tryParse(json['nilai'].toString()) ?? 0,
    );
  }
}