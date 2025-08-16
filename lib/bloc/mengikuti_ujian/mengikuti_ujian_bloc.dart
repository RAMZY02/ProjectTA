import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/mengikuti_ujian/mengikuti_ujian_event.dart';
import 'package:project_ta/bloc/mengikuti_ujian/mengikuti_ujian_state.dart';
import 'package:project_ta/models/mengikuti_ujian_model.dart';
import 'package:http/http.dart' as http;

class MengikutiUjianBloc extends Bloc<MengikutiUjianEvent, MengikutiUjianState> {
  MengikutiUjianBloc() : super(MengikutiUjianInitial()) {
    on<Initialize>(onInitial);
    on<FetchMengikutiUjian>(onFetchMengikutiUjian);
    on<FetchMengikutiUjianById>(onFetchMengikutiUjianById);
    on<CreateMengikutiUjian>(onCreateMengikutiUjian);
    on<UpdateMengikutiUjian>(onUpdateMengikutiUjian);
  }

  Future<void> onInitial(Initialize event, Emitter<MengikutiUjianState> emit) async{
    emit(MengikutiUjianInitial());
  }

  Future<void> onFetchMengikutiUjian(FetchMengikutiUjian event, Emitter<MengikutiUjianState> emit) async{
    emit(MengikutiUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/mengikuti-ujian');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final ikutUjian = data.map((ikut) => MengikutiUjianModel.fromJson(ikut)).toList();
        print(ikutUjian);
        emit(MengikutiUjianLoaded(mengikutiUjian: ikutUjian));
      } else {
        emit(MengikutiUjianError(message: 'Failed to load Mengikuti Ujian'));
      }
    } catch (e) {
      print(e);
      emit(MengikutiUjianError(message: 'Error: $e'));
    }
  }

  Future<void> onFetchMengikutiUjianById(FetchMengikutiUjianById event, Emitter<MengikutiUjianState> emit) async{
    emit(MengikutiUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/mengikuti-ujian/${event.userId}/${event.ujianId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print("ini body");
      print(response.body);
      final data = json.decode(response.body);
      print("ini data");
      print(data);

      if (response.statusCode == 200) {
        final ikut = MengikutiUjianModel.fromJson(data);
        print("ini ikut");
        print(ikut);
        emit(MengikutiUjianByIdLoaded(mengikutiUjian: ikut));
      } else {
        emit(MengikutiUjianError(message: 'Failed to load Mengikuti Ujian'));
      }
    } catch (e) {
      print(e);
      emit(MengikutiUjianError(message: 'Error: $e'));
    }
  }

  Future<void> onCreateMengikutiUjian(CreateMengikutiUjian event, Emitter<MengikutiUjianState> emit) async{
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/mengikuti-ujian');
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'id_user' : event.userId,
            'id_ujian' : event.ujianId,
          })
      );

      print('ini bodynya create kupon');
      print(response.body);
      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 201) {
        final ikut = MengikutiUjianModel.fromJson(data);
        print(ikut);
        emit(MengikutiUjianInitial());
      } else {
        emit(MengikutiUjianError(message: 'Failed to load Mengikuti Ujian'));
      }
    } catch (e) {
      print("ini errornya create Mengikuti Ujian");
      print(e);
      emit(MengikutiUjianError(message: 'Error: $e'));
    }
  }

  Future<void> onUpdateMengikutiUjian(UpdateMengikutiUjian event, Emitter<MengikutiUjianState> emit) async{
    emit(MengikutiUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/mengikuti-ujian/selesai/${event.userId}/${event.ujianId}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        add(FetchMengikutiUjian(token: event.token, userId: event.userId));
      } else {
        emit(MengikutiUjianError(message: 'Failed to load kupons'));
      }
    } catch (e) {
      print(e);
      emit(MengikutiUjianError(message: 'Error: $e'));
    }
  }
}