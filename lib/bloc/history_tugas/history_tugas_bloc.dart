import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/history_tugas/history_tugas_event.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_state.dart';
import 'package:project_ta/models/history_tugas_model.dart';

class HistoryTugasBloc extends Bloc<HistoryTugasEvent, HistoryTugasState> {

  final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  HistoryTugasBloc() : super(HistoryTugasInitial()) {
    on<InitialHistoryTugas>(onInitial);
    on<FetchHistoryTugas>(onFetchHistoryTugas);
    on<FetchHistoryTugasSiswa>(onFetchHistoryTugasSiswa);
    on<CreateHistoryTugas>(onCreateHistoryTugas);
    on<UpdateHistoryTugas>(onUpdateHistoryTugas);
  }

  Future<void> onInitial(InitialHistoryTugas event, Emitter<HistoryTugasState> emit) async {
    emit(HistoryTugasInitial());
  }

  Future<void> onFetchHistoryTugas(FetchHistoryTugas event, Emitter<HistoryTugasState> emit) async {
    emit(HistoryTugasLoading());
    final url = Uri.parse('$baseUrl/api/history-tugas/');
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
      print("ini tugas history 1");
      print(data);

      if (response.statusCode == 200) {
        final histories = data.map((history) => HistoryTugasModel.fromJson(history)).toList();
        print("ini tugas history");
        emit(HistoryTugasLoaded(histories: histories));
      } else {
        emit(HistoryTugasError(message: 'Failed to load histories'));
      }
    } catch (e) {
      print(e);
      emit(HistoryTugasError(message: 'Error: $e'));
    }
  }

  Future<void> onFetchHistoryTugasSiswa(FetchHistoryTugasSiswa event, Emitter<HistoryTugasState> emit) async {
    emit(HistoryTugasLoading());
    final url = Uri.parse('$baseUrl/api/history-tugas/${event.userId}/${event.tugasId}');
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
      print("ini tugas history siswa 1");
      print(data);

      if (response.statusCode == 200) {
        final histories = data.map((history) => HistoryTugasModel.fromJson(history)).toList();
        print("ini tugas history siswa");
        emit(HistoryTugasLoaded(histories: histories));
      } else {
        emit(HistoryTugasError(message: 'Failed to load histories'));
      }
    } catch (e) {
      print(e);
      emit(HistoryTugasError(message: 'Error: $e'));
    }
  }

  Future<void> onCreateHistoryTugas(CreateHistoryTugas event, Emitter<HistoryTugasState> emit) async {
    emit(HistoryTugasLoading());
    final url = Uri.parse('$baseUrl/api/history-tugas/');
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'id_user': event.userId,
            'id_tugas': event.tugasId,
          })
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        add(InitialHistoryTugas());
      } else {
        emit(HistoryTugasError(message: 'Failed to create history tugas'));
      }
    } catch (e) {
      emit(HistoryTugasError(message: 'Error: $e'));
    }
  }

  Future<void> onUpdateHistoryTugas(UpdateHistoryTugas event, Emitter<HistoryTugasState> emit) async {
    emit(HistoryTugasLoading());
    final url = Uri.parse('$baseUrl/api/history-tugas');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'id_pengumpulan_tugas': event.pengumpulanTugasId,
            'timestamps': event.timestamps.toIso8601String(),
          })
      );

      if (response.statusCode == 200) {
        add(InitialHistoryTugas());
      } else {
        emit(HistoryTugasError(message: 'Failed to update history tugas'));
      }
    } catch (e) {
      emit(HistoryTugasError(message: 'Error: $e'));
    }
  }
}