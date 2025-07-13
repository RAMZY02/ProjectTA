class UserModel {
  final int id;
  final String email;
  final String nama;
  final String role;
  final String kelas;
  final int poin;
  final String profpic;
  final DateTime timestamps;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    required this.kelas,
    required this.poin,
    required this.profpic,
    required this.timestamps,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'],
      role: json['role'],
      kelas: json['kelas'],
      poin: json['poin'] ?? 0,
      profpic: json['profpic'] ?? '-',
      timestamps: DateTime.parse(json['timestamps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'kelas': kelas,
      'poin': poin,
      'profpic': profpic,
      'timestamps': timestamps,
    };
  }
}