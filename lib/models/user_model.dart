class UserModel {
  final int id;
  final String email;
  final String nama;
  final String role;
  final String nomor_ortu;
  final String kelas;
  final String mapel;
  final int poin;
  final String profpic;
  final DateTime timestamps;
  final String uts;
  final String uas;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    required this.nomor_ortu,
    required this.kelas,
    required this.mapel,
    required this.poin,
    required this.profpic,
    required this.timestamps,
    this.uts = '-',
    this.uas= '-',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'],
      role: json['role'],
      nomor_ortu: json['nomor_ortu'],
      kelas: json['kelas'],
      mapel: json['mapel'],
      poin: json['poin'] ?? 0,
      profpic: json['profpic'] ?? '-',
      timestamps: DateTime.parse(json['timestamps']),
      uts: json['uts'] ?? '-',
      uas: json['uas'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'nomor_ortu': nomor_ortu,
      'kelas': kelas,
      'mapel': mapel,
      'poin': poin,
      'profpic': profpic,
      'timestamps': timestamps,
      'uts': uts,
      'uas': uas,
    };
  }
}