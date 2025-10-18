import 'package:project_ta/models/tugas_model.dart';

abstract class TugasState {}

class TugasInitial extends TugasState {}

class TugasLoading extends TugasState {}

class TugasLoaded extends TugasState {
  final List<TugasModel> tugas;

  TugasLoaded({required this.tugas});
}

class TugasOperationSuccess extends TugasState {
  final String message;

  TugasOperationSuccess({required this.message});
}

class TugasError extends TugasState {
  final String message;

  TugasError({required this.message});
}

class TugasFormLoaded extends TugasState {
  final TugasModel? tugas;

  TugasFormLoaded({this.tugas});
}