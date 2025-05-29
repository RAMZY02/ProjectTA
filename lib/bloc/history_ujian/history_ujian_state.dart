import 'package:project_ta/models/history_ujian_model.dart';

abstract class HistoryUjianState {}

class HistoryUjianInitial extends HistoryUjianState {}

class HistoryUjianLoading extends HistoryUjianState{}

class HistoryUjianLoaded extends HistoryUjianState{

  final List<HistoryUjianModel> histories;

  HistoryUjianLoaded({required this.histories});
}

class HistoryUjianError extends HistoryUjianState{
  String message;

  HistoryUjianError({required this.message});
}