import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_event.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_state.dart';
import 'package:http/http.dart' as http;

import '../../models/jawaban_siswa_model.dart';

class JawabanSiswaBloc extends Bloc<JawabanSiswaEvent, JawabanSiswaState> {
  JawabanSiswaBloc() : super(JawabanSiswaInitial()) {
    on<Initial>(onInitial);
    on<FetchJawabanSiswa>(onFetchJawabanSiswa);
    on<CreateJawabanSiswa>(onCreateJawabanSiswa);
  }

  Future<void> onInitial(Initial event, Emitter<JawabanSiswaState> emit) async{
    emit(JawabanSiswaInitial());
  }

  Future<void> onFetchJawabanSiswa(FetchJawabanSiswa event, Emitter<JawabanSiswaState> emit) async{
    emit(JawabanSiswaLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/jawaban-siswa/${event.userId}/${event.ujianId}/${event.soalId}');
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
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/kupon');
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'id_hadiah' : event.hadiah.id,
            'id_user' : event.userId,
            'tipe' : event.hadiah.kategori
          })
      );

      print('ini bodynya create kupon');
      print(response.body);
      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 201) {
        final kupon = JawabanSiswaModel.fromJson(data);
        print(kupon);
        emit(JawabanSiswaInitial());
      } else {
        emit(JawabanSiswaError(message: 'Failed to load kupons'));
      }
    } catch (e) {
      print("ini errornya create kupon");
      print(e);
      emit(JawabanSiswaError(message: 'Error: $e'));
    }
  }
}