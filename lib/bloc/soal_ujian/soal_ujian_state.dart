// bloc/soal_ujian/soal_ujian_state.dart
import '../../models/soal_model.dart';

abstract class SoalUjianState {}

class SoalUjianInitial extends SoalUjianState {}

class SoalUjianLoading extends SoalUjianState {}

class SoalUjianLoaded extends SoalUjianState {
  final List<SoalModel> soalList;

  SoalUjianLoaded({required this.soalList});
}

class JawabanSubmitted extends SoalUjianState {
  final bool isCorrect;

  JawabanSubmitted({required this.isCorrect});
}

class SoalUjianError extends SoalUjianState {
  final String message;

  SoalUjianError({required this.message});
}