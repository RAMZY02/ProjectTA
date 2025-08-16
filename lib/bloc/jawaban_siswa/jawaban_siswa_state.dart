import 'package:project_ta/models/jawaban_siswa_model.dart';

abstract class JawabanSiswaState {}

class JawabanSiswaInitial extends JawabanSiswaState {}

class JawabanSiswaLoading extends JawabanSiswaState{}

class JawabanSiswaLoaded extends JawabanSiswaState{

  final JawabanSiswaModel jawaban;

  JawabanSiswaLoaded({required this.jawaban});
}

class JawabanSiswaError extends JawabanSiswaState{
  String message;

  JawabanSiswaError({required this.message});
}