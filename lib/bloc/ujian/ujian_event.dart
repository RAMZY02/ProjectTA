// bloc/ujian/ujian_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class UjianEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitUjian extends UjianEvent {}

class FetchUjian extends UjianEvent {
  final String token;
  final int userId;
  final String kelas;

  FetchUjian({required this.token, required this.userId, required this.kelas});

  @override
  List<Object> get props => [token];
}

class FetchUjian2 extends UjianEvent {
  final String token;

  FetchUjian2({required this.token});

  @override
  List<Object> get props => [token];
}

class FetchAllUjianByIdMapel extends UjianEvent {
  final String token;
  final int id_mapel;

  FetchAllUjianByIdMapel({required this.token, required this.id_mapel});

  @override
  List<Object> get props => [token];
}

class FetchAllUjianByIdGuru extends UjianEvent {
  final String token;
  final int id_guru;

  FetchAllUjianByIdGuru({required this.token, required this.id_guru});

  @override
  List<Object> get props => [token];
}

class FetchKoreksiUjianByIdGuru extends UjianEvent {
  final String token;
  final int id_guru;

  FetchKoreksiUjianByIdGuru({required this.token, required this.id_guru});

  @override
  List<Object> get props => [token];
}

class FetchUjianByIdMapel extends UjianEvent {
  final String token;
  final int id_mapel;

  FetchUjianByIdMapel({required this.token, required this.id_mapel});

  @override
  List<Object> get props => [token];
}

class AddUjian extends UjianEvent {
  final String token;
  final String nama;
  final int id_mapel;
  final String tingkatan;
  final String kelas;
  final String tipe_soal;
  final String tipe_ujian;
  final DateTime tanggal;
  final TimeOfDay mulai;
  final TimeOfDay selesai;
  final String deskripsi;
  final String kode;
  final int id_guru;

  AddUjian({
    required this.token,
    required this.nama,
    required this.id_mapel,
    required this.tingkatan,
    required this.kelas,
    required this.tipe_soal,
    required this.tipe_ujian,
    required this.tanggal,
    required this.mulai,
    required this.selesai,
    required this.deskripsi,
    required this.kode,
    required this.id_guru,
  });

  @override
  List<Object> get props => [token];
}

class UpdateUjian extends UjianEvent {
  final String token;
  final int id_ujian;
  final String nama;
  final int id_mapel;
  final String tingkatan;
  final String kelas;
  final String tipe_soal;
  final String tipe_ujian;
  final DateTime tanggal;
  final TimeOfDay mulai;
  final TimeOfDay selesai;
  final String deskripsi;
  final int id_guru;

  UpdateUjian({
    required this.token,
    required this.id_ujian,
    required this.nama,
    required this.id_mapel,
    required this.tingkatan,
    required this.kelas,
    required this.tipe_soal,
    required this.tipe_ujian,
    required this.tanggal,
    required this.mulai,
    required this.selesai,
    required this.deskripsi,
    required this.id_guru,
  });

  @override
  List<Object> get props => [token];
}

class DeleteUjian extends UjianEvent {
  final String token;
  final int id_ujian;

  DeleteUjian({
    required this.token,
    required this.id_ujian
  });

  @override
  List<Object> get props => [token];
}

class CekUjianBerlangsung extends UjianEvent {
  final String token;
  final int id_user;

  CekUjianBerlangsung({
    required this.token,
    required this.id_user
  });

  @override
  List<Object> get props => [token];
}


