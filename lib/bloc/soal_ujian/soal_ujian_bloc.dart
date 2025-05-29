// bloc/soal_ujian/soal_ujian_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/models/soal_model.dart';

class SoalUjianBloc extends Bloc<SoalUjianEvent, SoalUjianState> {
  SoalUjianBloc() : super(SoalUjianInitial()) {
    on<InitSoalUjian>(_onInit);
    on<FetchSoalUjian>(_onFetchSoalUjian);
    on<SubmitJawaban>(_onSubmitJawaban);
  }

  Future<void> _onFetchSoalUjian(
    FetchSoalUjian event,
    Emitter<SoalUjianState> emit,
  ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal/${event.ujianId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      } else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onSubmitJawaban(
      SubmitJawaban event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('http://192.168.1.26:3000/api/soal/${event.soalId}/submit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({'jawaban': event.jawaban}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(JawabanSubmitted(isCorrect: data['isCorrect']));
      } else {
        emit(SoalUjianError(message: 'Gagal submit jawaban'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onInit(InitSoalUjian event, Emitter<SoalUjianState> emit) async {
    emit(SoalUjianInitial());
  }
}