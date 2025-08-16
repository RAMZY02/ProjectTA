import 'package:project_ta/models/mengikuti_ujian_model.dart';

abstract class MengikutiUjianState {}

class MengikutiUjianInitial extends MengikutiUjianState {}

class MengikutiUjianLoading extends MengikutiUjianState{}

class MengikutiUjianLoaded extends MengikutiUjianState{

  final List<MengikutiUjianModel> mengikutiUjian;

  MengikutiUjianLoaded({required this.mengikutiUjian});
}

class MengikutiUjianByIdLoaded extends MengikutiUjianState{

  final MengikutiUjianModel mengikutiUjian;

  MengikutiUjianByIdLoaded({required this.mengikutiUjian});
}

class MengikutiUjianError extends MengikutiUjianState{
  String message;

  MengikutiUjianError({required this.message});
}