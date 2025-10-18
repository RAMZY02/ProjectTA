class SoalModel {
  final int id;
  final int idUjian;
  final String tipe;
  final String soal;
  final String opsiA;
  final String opsiB;
  final String opsiC;
  final String opsiD;
  final String opsiE;
  final String jawaban;
  final String pembahasan;
  final String linkVideo;
  final String linkGambar;
  final String linkAudio;
  final String jawabanSiswa;
  final int nilaiSiswa;

  SoalModel({
    required this.id,
    required this.idUjian,
    required this.tipe,
    required this.soal,
    required this.opsiA,
    required this.opsiB,
    required this.opsiC,
    required this.opsiD,
    required this.opsiE,
    required this.jawaban,
    required this.pembahasan,
    required this.linkVideo,
    required this.linkGambar,
    required this.linkAudio,
    required this.jawabanSiswa,
    required this.nilaiSiswa,
  });

  factory SoalModel.fromJson(Map<String, dynamic> json) {
    return SoalModel(
      id: json['id'],
      idUjian: json['id_ujian'],
      tipe: json['tipe'],
      soal: json['soal'],
      opsiA: json['opsi_a'] ?? '-',
      opsiB: json['opsi_b'] ?? '-',
      opsiC: json['opsi_c'] ?? '-',
      opsiD: json['opsi_d'] ?? '-',
      opsiE: json['opsi_e'] ?? '-',
      jawaban: json['jawaban'] ?? '-',
      pembahasan: json['pembahasan'],
      linkVideo: json['link_video'] ?? '-',
      linkGambar: json['link_gambar'] ?? '-',
      linkAudio: json['link_audio'] ?? '-',
      jawabanSiswa: json['jawabanSiswa'] ?? '-',
      nilaiSiswa: json['nilaiSiswa'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_ujian': idUjian,
      'tipe': tipe,
      'soal': soal,
      'opsi_a': opsiA,
      'opsi_b': opsiB,
      'opsi_c': opsiC,
      'opsi_d': opsiD,
      'opsi_e': opsiE,
      'jawaban': jawaban,
      'pembahasan': pembahasan,
      'link_video': linkVideo,
      'link_gambar': linkGambar,
      'link_audio': linkAudio,
      'jawabanSiswa': jawabanSiswa,
      'nilaiSiswa': nilaiSiswa,
    };
  }

  SoalModel copyWith({
    int? id,
    int? idUjian,
    String? tipe,
    String? soal,
    String? opsiA,
    String? opsiB,
    String? opsiC,
    String? opsiD,
    String? opsiE,
    String? jawaban,
    String? pembahasan,
    String? linkVideo,
    String? linkGambar,
    String? linkAudio,
    String? jawabanSiswa,
    int? nilaiSiswa
  }) {
    return SoalModel(
      id: id ?? this.id,
      idUjian: idUjian ?? this.idUjian,
      tipe: tipe ?? this.tipe,
      soal: soal ?? this.soal,
      opsiA: opsiA ?? this.opsiA,
      opsiB: opsiB ?? this.opsiB,
      opsiC: opsiC ?? this.opsiC,
      opsiD: opsiD ?? this.opsiD,
      opsiE: opsiE ?? this.opsiE,
      jawaban: jawaban ?? this.jawaban,
      pembahasan: pembahasan ?? this.pembahasan,
      linkVideo: linkVideo ?? this.linkVideo,
      linkGambar: linkGambar ?? this.linkGambar,
      linkAudio: linkAudio ?? this.linkAudio,
      jawabanSiswa: jawabanSiswa ?? this.jawabanSiswa,
      nilaiSiswa: nilaiSiswa ?? this.nilaiSiswa
    );
  }
}