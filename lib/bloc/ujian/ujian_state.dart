// bloc/ujian/ujian_state.dart
import '../../models/ujian_model.dart';

abstract class UjianState {}

class UjianInitial extends UjianState {}

class UjianLoading extends UjianState {}

class UjianLoaded extends UjianState {
  final List<UjianModel> ujianList;

  UjianLoaded({required this.ujianList});
}

class UjianError extends UjianState {
  final String message;

  UjianError({required this.message});
}