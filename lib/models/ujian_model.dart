import 'package:flutter/material.dart';

class UjianModel {
  final int id;
  final String nama;
  final int id_mapel;
  final int id_tahun_pelajaran;
  final String mapel;
  final String tingkatan;
  final String kelas;
  final String tipe_soal;
  final String tipe_ujian;
  final DateTime tanggal;
  final TimeOfDay mulai;
  final TimeOfDay selesai;
  final int jumlahSoal;
  final String deskripsi;
  final String kode;
  final int id_guru;
  final String guru;
  final List<dynamic> userDone;
  final bool isDone;
  final int totalSiswa;
  final int diperiksa;

  UjianModel({
    required this.id,
    required this.nama,
    required this.id_mapel,
    required this.id_tahun_pelajaran,
    required this.mapel,
    required this.tingkatan,
    required this.kelas,
    required this.tipe_soal,
    required this.tipe_ujian,
    required this.tanggal,
    required this.mulai,
    required this.selesai,
    required this.jumlahSoal,
    required this.deskripsi,
    required this.kode,
    required this.id_guru,
    required this.guru,
    required this.userDone,
    this.isDone = false,
    this.totalSiswa = 0,
    this.diperiksa = 0,
  });

  factory UjianModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    return UjianModel(
      id: json['id'],
      nama: json['nama'],
      id_mapel: json['id_mapel'],
      id_tahun_pelajaran: json['id_tahun_pelajaran'],
      mapel: json['mapel'],
      tingkatan: json['tingkatan'],
      kelas: json['kelas'],
      tipe_soal: json['tipe_soal'],
      tipe_ujian: json['tipe_ujian'],
      tanggal: DateTime.parse(json['tanggal']),
      mulai: _parseTime(json['mulai']),
      selesai: _parseTime(json['selesai']),
      jumlahSoal: json['jumlah_soal'],
      deskripsi: json['deskripsi'],
      kode: json['kode'],
      id_guru: json['id_guru'],
      guru: json['guru'] ?? '',
      userDone: json['userDone'] ?? [],
      isDone: (json['userDone'] as List<dynamic>).contains(currentUserId),
      totalSiswa: json['totalSiswa'] ?? 0,
      diperiksa: json['diperiksa'] ?? 0
    );
  }

  factory UjianModel.fromJson2(Map<String, dynamic> json) {
    return UjianModel(
      id: json['id'],
      nama: json['nama'],
      id_mapel: json['id_mapel'],
      id_tahun_pelajaran: json['id_tahun_pelajaran'],
      mapel: json['mapel'],
      tingkatan: json['tingkatan'],
      kelas: json['kelas'],
      tipe_soal: json['tipe_soal'],
      tipe_ujian: json['tipe_ujian'],
      tanggal: DateTime.parse(json['tanggal']),
      mulai: _parseTime(json['mulai']),
      selesai: _parseTime(json['selesai']),
      jumlahSoal: json['jumlah_soal'],
      deskripsi: json['deskripsi'],
      kode: json['kode'],
      id_guru: json['id_guru'],
      guru: json['guru'] ?? '',
      userDone: json['userDone'] ?? [],
      totalSiswa: json['totalSiswa'] ?? 0,
      diperiksa: json['diperiksa'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'id_mapel': id_mapel,
      'tipe_soal': tipe_soal,
      'tipe_ujian': tipe_ujian,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'mulai': '${mulai.hour}:${mulai.minute.toString().padLeft(2, '0')}',
      'selesai': '${selesai.hour}:${selesai.minute.toString().padLeft(2, '0')}',
      'jumlah_soal': jumlahSoal,
      'deskripsi': deskripsi,
      'id_guru': id_guru,
      'guru': guru,
      'userDone': userDone,
      'isDone': isDone,
      'totalSiswa': totalSiswa,
      'diperiksa': diperiksa,
    };
  }

  static TimeOfDay _parseTime(String s) {
    List<String> parts = s.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}