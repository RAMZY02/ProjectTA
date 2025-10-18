// bloc/soal_ujian/soal_ujian_state.dart
import '../../models/soal_model.dart';

abstract class SoalUjianState {}

class SoalUjianInitial extends SoalUjianState {}

class SoalUjianLoading extends SoalUjianState {}

class SoalUjianLoaded extends SoalUjianState {
  final List<SoalModel> soalList;

  SoalUjianLoaded({required this.soalList});
}

class SoalUjianNotFound extends SoalUjianState{
  final String message;

  SoalUjianNotFound({required this.message});
}

class JawabanSubmitted extends SoalUjianState {
  final bool isCorrect;

  JawabanSubmitted({required this.isCorrect});
}

class SoalUjianError extends SoalUjianState {
  final String message;

  SoalUjianError({required this.message});
}

// Tambahkan state-state AI
class SoalUjianAILoading extends SoalUjianState {
  @override
  List<Object> get props => [];
}

class SoalUjianAILoaded extends SoalUjianState {
  final List<SoalModel> aiSoalList;

  SoalUjianAILoaded(this.aiSoalList);

  @override
  List<Object> get props => [aiSoalList];
}

class SoalUjianAIError extends SoalUjianState {
  final String message;

  SoalUjianAIError(this.message);

  @override
  List<Object> get props => [message];
}

class SoalUjianSuccess extends SoalUjianState {
  final String message;

  SoalUjianSuccess(this.message);

  @override
  List<Object> get props => [message];
}