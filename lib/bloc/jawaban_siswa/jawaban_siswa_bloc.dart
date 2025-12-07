import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_event.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_state.dart';
import 'package:http/http.dart' as http;

import '../../models/jawaban_siswa_model.dart';

class JawabanSiswaBloc extends Bloc<JawabanSiswaEvent, JawabanSiswaState> {

  final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  JawabanSiswaBloc() : super(JawabanSiswaInitial()) {
    on<Initial>(onInitial);
    on<FetchJawabanSiswa>(onFetchJawabanSiswa);
    on<CreateJawabanSiswa>(onCreateJawabanSiswa);
    on<UpdateJawabanSiswa>(onUpdateJawabanSiswa);
  }

  Future<void> onInitial(Initial event, Emitter<JawabanSiswaState> emit) async{
    emit(JawabanSiswaInitial());
  }

  Future<void> onFetchJawabanSiswa(FetchJawabanSiswa event, Emitter<JawabanSiswaState> emit) async{
    emit(JawabanSiswaLoading());
    final url = Uri.parse('$baseUrl/api/jawaban-siswa/${event.userId}/${event.ujianId}/${event.soalId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print('ini jawaban siswa');
      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final jawaban = JawabanSiswaModel.fromJson(data);
        print(jawaban);
        emit(JawabanSiswaLoaded(jawaban: jawaban));
      } else {
        emit(JawabanSiswaError(message: 'Failed to load kupons'));
      }
    } catch (e) {
      print(e);
      emit(JawabanSiswaError(message: 'Error: $e'));
    }
  }

  Future<void> onCreateJawabanSiswa(CreateJawabanSiswa event, Emitter<JawabanSiswaState> emit) async{
    final url = Uri.parse('$baseUrl/api/jawaban-siswa');
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'id_ujian' : event.ujianId,
            'id_soal' : event.soalId,
            'urutan' : event.urutan,
            'jawaban' : event.jawaban,
            'nilai' : event.nilai
          })
      );

      print('ini bodynya create jawaban siswa');
      print(response.body);
      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 201) {
        final jawabanSiswa = JawabanSiswaModel.fromJson(data);
        print(jawabanSiswa);
        emit(JawabanSiswaInitial());
      } else {
        emit(JawabanSiswaError(message: 'Failed to load jawaban siswa'));
      }
    } catch (e) {
      print("ini errornya create jawaban siswa");
      print(e);
      emit(JawabanSiswaError(message: 'Error: $e'));
    }
  }

  Future<void> onUpdateJawabanSiswa(UpdateJawabanSiswa event, Emitter<JawabanSiswaState> emit) async{
    final url = Uri.parse('$baseUrl/api/jawaban-siswa/${event.userId}/${event.ujianId}/${event.soalId}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'jawaban' : event.jawaban,
            'nilai' : event.nilai
          })
      );

      print('ini bodynya update jawaban siswa');
      print(response.body);
      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 201) {
        final jawabanSiswa = JawabanSiswaModel.fromJson(data);
        print(jawabanSiswa);
        emit(JawabanSiswaInitial());
      } else {
        emit(JawabanSiswaError(message: 'Failed to load jawaban siswa'));
      }
    } catch (e) {
      print("ini errornya create jawaban siswa");
      print(e);
      emit(JawabanSiswaError(message: 'Error: $e'));
    }
  }
}