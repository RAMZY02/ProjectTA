import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/history_ujian/history_ujian_event.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_state.dart';
import 'package:project_ta/models/history_ujian_model.dart';

class HistoryUjianBloc extends Bloc<HistoryUjianEvent, HistoryUjianState> {
  HistoryUjianBloc() : super(HistoryUjianInitial()) {
    on<InitialHistoryUjian>(onInitial);
    on<FetchHistoryUjian>(onFetchHistoryUjian);
    on<FetchHistoryUjianSiswa>(onFetchHistoryUjianSiswa);
  }

  Future<void> onInitial(InitialHistoryUjian event, Emitter<HistoryUjianState> emit) async{
    emit(HistoryUjianInitial());
  }

  Future<void> onFetchHistoryUjian(FetchHistoryUjian event, Emitter<HistoryUjianState> emit) async{
    emit(HistoryUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/history-ujian/${event.userId}');
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
      print("ini ujian history 1");
      print(data);

      if (response.statusCode == 200) {
        final histories = data.map((history) => HistoryUjianModel.fromJson(history)).toList();
        print("ini ujian history");
        emit(HistoryUjianLoaded(histories: histories));
      } else {
        emit(HistoryUjianError(message: 'Failed to load histories'));
      }
    } catch (e) {
      print(e);
      emit(HistoryUjianError(message: 'Error: $e'));
    }
  }

  Future<void> onFetchHistoryUjianSiswa(FetchHistoryUjianSiswa event, Emitter<HistoryUjianState> emit) async{
    emit(HistoryUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/history-ujian/uts-uas/${event.userId}');
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
      print("ini ujian history 1");
      print(data);

      if (response.statusCode == 200) {
        final histories = data.map((history) => HistoryUjianModel.fromJson(history)).toList();
        print("ini ujian history");
        emit(HistoryUjianLoaded(histories: histories));
      } else {
        emit(HistoryUjianError(message: 'Failed to load histories'));
      }
    } catch (e) {
      print(e);
      emit(HistoryUjianError(message: 'Error: $e'));
    }
  }
}