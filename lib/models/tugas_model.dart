class TugasModel {
  final int id;
  final int idUser;
  final int idTahunPelajaran;
  final String nama;
  final String deskripsi;
  final String kelas;
  final String linkVideo;
  final String linkGambar;
  final String linkAudio;
  final String linkFile;
  final DateTime deadline;
  final DateTime timestamp;
  bool mengumpulkan;

  TugasModel({
    required this.id,
    required this.idUser,
    required this.idTahunPelajaran,
    required this.nama,
    required this.deskripsi,
    required this.kelas,
    required this.linkVideo,
    required this.linkGambar,
    required this.linkAudio,
    required this.linkFile,
    required this.deadline,
    required this.timestamp,
    this.mengumpulkan = false,
  });

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: json['id'],
      idUser: json['id_user'],
      idTahunPelajaran: json['id_tahun_pelajaran'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      kelas: json['kelas'],
      linkVideo: json['link_video'],
      linkGambar: json['link_gambar'],
      linkAudio: json['link_audio'],
      linkFile: json['link_file'],
      deadline: DateTime.parse(json['deadline']),
      timestamp: DateTime.parse(json['timestamp']),
      mengumpulkan: json['mengumpulkan'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'nama': nama,
      'deskripsi': deskripsi,
      'kelas': kelas,
      'link_video': linkVideo,
      'link_gambar': linkGambar,
      'link_audio': linkAudio,
      'link_file': linkFile,
      'deadline': deadline.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

}