import 'package:project_ta/models/history_tugas_model.dart';

abstract class HistoryTugasState {}

class HistoryTugasInitial extends HistoryTugasState {}

class HistoryTugasLoading extends HistoryTugasState {}

class HistoryTugasLoaded extends HistoryTugasState {
  final List<HistoryTugasModel> histories;

  HistoryTugasLoaded({required this.histories});
}

class HistoryTugasError extends HistoryTugasState {
  final String message;

  HistoryTugasError({required this.message});
}