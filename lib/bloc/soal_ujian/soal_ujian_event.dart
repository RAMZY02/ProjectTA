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

  FetchSoalUjian({required this.token, required this.ujianId});

  @override
  List<Object> get props => [token, ujianId];
}

class SubmitJawaban extends SoalUjianEvent {
  final String token;
  final String soalId;
  final String jawaban;

  SubmitJawaban({
    required this.token,
    required this.soalId,
    required this.jawaban,
  });

  @override
  List<Object> get props => [token, soalId, jawaban];
}