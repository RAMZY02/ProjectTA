class KelasMengajarModel {
  final int id;
  final int idUser;
  final String kelas;
  final String keyStatus;

  KelasMengajarModel({
    required this.id,
    required this.idUser,
    required this.kelas,
    required this.keyStatus,
  });

  // Factory method untuk membuat object dari JSON
  factory KelasMengajarModel.fromJson(Map<String, dynamic> json) {
    return KelasMengajarModel(
      id: json['id'],
      idUser: json['id_user'],
      kelas: json['kelas'],
      keyStatus: json['key_status'],
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'kelas': kelas,
      'key_status': keyStatus,
    };
  }
}