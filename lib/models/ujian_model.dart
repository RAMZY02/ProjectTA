import 'package:flutter/material.dart';

class UjianModel {
  final int id;
  final String nama;
  final String mapel;
  final String tipe;
  final Duration durasi;
  final DateTime tanggal;
  final TimeOfDay mulai;
  final TimeOfDay selesai;
  final int jumlahSoal;
  final String deskripsi;
  final int id_guru;
  final String guru;

  UjianModel({
    required this.id,
    required this.nama,
    required this.mapel,
    required this.tipe,
    required this.durasi,
    required this.tanggal,
    required this.mulai,
    required this.selesai,
    required this.jumlahSoal,
    required this.deskripsi,
    required this.id_guru,
    required this.guru,
  });

  factory UjianModel.fromJson(Map<String, dynamic> json) {
    return UjianModel(
      id: json['id'],
      nama: json['nama'],
      mapel: json['mapel'],
      tipe: json['tipe'],
      durasi: _parseDuration(json['durasi']),
      tanggal: DateTime.parse(json['tanggal']),
      mulai: _parseTime(json['mulai']),
      selesai: _parseTime(json['selesai']),
      jumlahSoal: json['jumlah_soal'],
      deskripsi: json['deskripsi'],
      id_guru: json['id_guru'],
      guru: json['guru'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'mapel': mapel,
      'tipe': tipe,
      'durasi': '${durasi.inHours}:${(durasi.inMinutes % 60).toString().padLeft(2, '0')}:00',
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'mulai': '${mulai.hour}:${mulai.minute.toString().padLeft(2, '0')}',
      'selesai': '${selesai.hour}:${selesai.minute.toString().padLeft(2, '0')}',
      'jumlah_soal': jumlahSoal,
      'deskripsi': deskripsi,
      'id_guru': id_guru,
      'guru': guru,
    };
  }

  static Duration _parseDuration(String s) {
    List<String> parts = s.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
    );
  }

  static TimeOfDay _parseTime(String s) {
    List<String> parts = s.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}