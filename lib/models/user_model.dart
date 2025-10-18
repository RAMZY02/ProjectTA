import 'package:project_ta/models/pengumpulan_tugas_model.dart';
import 'package:project_ta/models/penilaian_tugas_model.dart';
import 'package:project_ta/models/ujian_harian_model.dart';

import 'laporan_tugas_model.dart';

class UserModel {
  final int id;
  final String email;
  final String nama;
  final String nis;
  final String nisn;
  final String role;
  final String nomor_ortu;
  final String kelas;
  final String agama;
  final int id_mapel;
  final String mapel;
  final String wali_kelas;
  final int poin;
  final String profpic;
  final DateTime timestamps;
  final String uts;
  final String uas;
  bool tidakNaik;
  int nilai;
  bool diperiksa;
  bool pengumpul;
  PengumpulanTugasModel? tugas;
  final List<UjianHarianModel>? ujianHarian; // Perhatikan tipe data ini
  final List<LaporanTugasModel>? laporanTugas; // Perhatikan tipe data ini
  final List<PenilaianTugasModel>? penilaianTugas; // Perhatikan tipe data ini

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.nis,
    required this.nisn,
    required this.role,
    required this.nomor_ortu,
    required this.kelas,
    required this.agama,
    required this.id_mapel,
    required this.mapel,
    required this.wali_kelas,
    required this.poin,
    required this.profpic,
    required this.timestamps,
    this.uts = '-',
    this.uas= '-',
    this.tidakNaik = false,
    this.nilai = 0,
    this.diperiksa = false,
    this.pengumpul = false,
    this.tugas,
    this.ujianHarian,
    this.laporanTugas,
    this.penilaianTugas,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'],
      nis: json['nis'],
      nisn: json['nisn'],
      role: json['role'],
      nomor_ortu: json['nomor_ortu'],
      kelas: json['kelas'],
      agama: json['agama'],
      id_mapel: json['id_mapel'],
      mapel: json['mapel'],
      wali_kelas: json['wali_kelas'],
      poin: json['poin'] ?? 0,
      profpic: json['profpic'] ?? '-',
      timestamps: DateTime.parse(json['timestamps']),
      uts: json['uts'] ?? '-',
      uas: json['uas'] ?? '-',
      nilai: json['nilai'] ?? 0,
      diperiksa: json['diperiksa'] ?? false,
      pengumpul: json['pengumpul'] ?? false,
      tugas: json['tugas'] != null ? PengumpulanTugasModel.fromJson(json['tugas']) : null,
      ujianHarian: json['ujian_harian'] != null
          ? (json['ujian_harian'] as List).map((data) => UjianHarianModel.fromJson(data)).toList()
          : null,
      laporanTugas: json['laporan_tugas'] != null
          ? (json['laporan_tugas'] as List).map((data) => LaporanTugasModel.fromJson(data)).toList()
          : null,
      penilaianTugas: json['penilaian_tugas'] != null
          ? (json['penilaian_tugas'] as List).map((data) => PenilaianTugasModel.fromJson(data)).toList()
          : null,
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
      'id_mapel': id_mapel,
      'poin': poin,
      'profpic': profpic,
      'timestamps': timestamps,
      'uts': uts,
      'uas': uas,
    };
  }
}