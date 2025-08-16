// bloc/soal_ujian/soal_ujian_event.dart
import 'package:equatable/equatable.dart';

abstract class SoalUjianEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitSoalUjian extends SoalUjianEvent {}

class FetchSoalUjian extends SoalUjianEvent {
  final String token;
  final int ujianId;
  final int userId;

  FetchSoalUjian({required this.token, required this.ujianId, required this.userId});

  @override
  List<Object> get props => [token, ujianId];
}

class FetchSoalUjian2 extends SoalUjianEvent {
  final String token;
  final int ujianId;

  FetchSoalUjian2({required this.token, required this.ujianId});

  @override
  List<Object> get props => [token, ujianId];
}

class FetchSoalUjian3 extends SoalUjianEvent {
  final String token;
  final int ujianId;
  final int userId;

  FetchSoalUjian3({required this.token, required this.ujianId, required this.userId});

  @override
  List<Object> get props => [token, ujianId];
}

class AddSoal extends SoalUjianEvent {
  final String token;
  final Map<String, Object?> soalData;

  AddSoal({required this.token, required this.soalData});

  @override
  List<Object> get props => [token, soalData];
}

class UpdateSoal extends SoalUjianEvent {
  final String token;
  final Map<String, Object?> soalData;

  UpdateSoal({required this.token, required this.soalData});

  @override
  List<Object> get props => [token, soalData];
}

class DeleteSoal extends SoalUjianEvent {
  final String token;
  final int id;
  final int id_ujian;

  DeleteSoal({required this.token, required this.id, required this.id_ujian});

  @override
  List<Object> get props => [token, id];
}