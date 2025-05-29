class MengikutiUjianModel {
  final int id;
  final int idUser;
  final int idUjian;
  final String status;

  MengikutiUjianModel({
    required this.id,
    required this.idUser,
    required this.idUjian,
    required this.status,
  });

  factory MengikutiUjianModel.fromJson(Map<String, dynamic> json) {
    return MengikutiUjianModel(
      id: json['id'],
      idUser: json['id_user'] ?? 0,
      idUjian: json['id_ujian'] ?? 0,
      status: json['status'] ?? 'tidak hadir',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_ujian': idUjian,
      'status': status,
    };
  }
}