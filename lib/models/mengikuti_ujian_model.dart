class MengikutiUjianModel {
  final int id;
  final int idUser;
  final int idUjian;
  final String kehadiran;
  final String selesai;

  MengikutiUjianModel({
    required this.id,
    required this.idUser,
    required this.idUjian,
    required this.kehadiran,
    required this.selesai,
  });

  factory MengikutiUjianModel.fromJson(Map<String, dynamic> json) {
    return MengikutiUjianModel(
      id: json['id'],
      idUser: json['id_user'] ?? 0,
      idUjian: json['id_ujian'] ?? 0,
      kehadiran: json['kehadiran'] ?? 'true',
      selesai: json['selesai'] ?? 'false',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_ujian': idUjian,
      'kehadiran': kehadiran,
      'selesai': selesai,
    };
  }
}