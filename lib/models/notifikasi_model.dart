class NotifikasiModel {
  final int id;
  final int idUser;
  final String icon;
  final String warna;
  final String judul;
  final String pesan;
  final DateTime waktu;
  final String status;

  NotifikasiModel({
    required this.id,
    required this.idUser,
    required this.icon,
    required this.warna,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.status,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'],
      idUser: json['id_user'],
      icon: json['icon'],
      warna: json['warna'],
      judul: json['judul'],
      pesan: json['pesan'],
      waktu: DateTime.parse(json['waktu']),
      status: json['status'] ?? 'belum dibaca',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'icon': icon,
      'warna': warna,
      'judul': judul,
      'pesan': pesan,
      'waktu': waktu.toIso8601String(),
      'status': status,
    };
  }
}