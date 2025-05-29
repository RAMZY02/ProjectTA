import 'package:project_ta/models/hadiah_model.dart';

abstract class HadiahState {}

class HadiahInitial extends HadiahState {}

class HadiahLoading extends HadiahState {}

class HadiahLoaded extends HadiahState {
  List<HadiahModel> hadiah;

  HadiahLoaded({required this.hadiah});
}

class HadiahError extends HadiahState{
  String message;

  HadiahError({required this.message});
}