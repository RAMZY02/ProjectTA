import 'package:project_ta/models/WA_model.dart';

abstract class WaState {}

class WaInitial extends WaState {}

class WaLoading extends WaState {}

class WaLoaded extends WaState {
  final bool success;
  final String message;
  final WaModel data;

  WaLoaded({required this.success, required this.message, required this.data});
}

class WaError extends WaState {
  final String message;

  WaError({required this.message});
}
