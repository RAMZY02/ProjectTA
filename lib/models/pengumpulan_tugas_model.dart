import 'package:project_ta/models/user_model.dart';

class PengumpulanTugasModel {
  final int id;
  final int idUser;
  final int idTugas;
  final String linkVideo;
  final String linkGambar;
  final String linkAudio;
  final String linkFile;
  final String deskripsi;
  final int nilai;
  final DateTime timestamp;
  UserModel? siswa;

  PengumpulanTugasModel({
    required this.id,
    required this.idUser,
    required this.idTugas,
    required this.linkVideo,
    required this.linkGambar,
    required this.linkAudio,
    required this.linkFile,
    required this.deskripsi,
    required this.nilai,
    required this.timestamp,
    this.siswa,
  });

  // Factory method untuk membuat object dari JSON
  factory PengumpulanTugasModel.fromJson(Map<String, dynamic> json) {
    return PengumpulanTugasModel(
      id: json['id'],
      idUser: json['id_user'],
      idTugas: json['id_tugas'],
      linkVideo: json['link_video'] ?? '-',
      linkGambar: json['link_gambar'] ?? '-',
      linkAudio: json['link_audio'] ?? '-',
      linkFile: json['link_file'] ?? '-',
      deskripsi: json['deskripsi'] ?? '-',
      nilai: json['nilai'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      siswa:  json['siswa'] != null ? UserModel.fromJson(json['siswa']) : null,
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_tugas': idTugas,
      'link_video': linkVideo,
      'link_gambar': linkGambar,
      'link_audio': linkAudio,
      'link_file': linkFile,
      'deskripsi': deskripsi,
      'timestamp': timestamp.toIso8601String(),
    };
  }

}