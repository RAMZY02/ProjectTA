import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/tugas_model.dart';
import 'tugas_event.dart';
import 'tugas_state.dart';

class TugasBloc extends Bloc<TugasEvent, TugasState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  TugasBloc() : super(TugasInitial()) {
    on<TugasInit>(_onInit);
    on<FetchTugas>(_onFetchTugas);
    on<FetchTugasByKelas>(_onFetchTugasByKelas);
    on<FetchTugasByIdUser>(_onFetchTugasByIdUser);
    on<CreateTugas>(_onCreateTugas);
    on<UpdateTugas>(_onUpdateTugas);
    on<DeleteTugas>(_onDeleteTugas);
  }

  Future<void> _onInit(TugasInit event, Emitter<TugasState> emit) async {
    emit(TugasInitial());
  }

  Future<void> _onFetchTugas(FetchTugas event, Emitter<TugasState> emit) async {
    emit(TugasLoading());

    final url = Uri.parse('$baseUrl/api/tugas');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        final List<TugasModel> tugasList = data
            .map((json) => TugasModel.fromJson(json))
            .toList();

        emit(TugasLoaded(tugas: tugasList));
      } else {
        emit(TugasError(message: 'Failed to load tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TugasError(message: 'Error fetching tugas: $e'));
    }
  }

  Future<void> _onFetchTugasByKelas(FetchTugasByKelas event, Emitter<TugasState> emit) async {
    emit(TugasLoading());

    final url = Uri.parse('$baseUrl/api/tugas/kelas/${event.kelas}/${event.id_user}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        final List<TugasModel> tugasList = data
            .map((json) => TugasModel.fromJson(json))
            .toList();

        emit(TugasLoaded(tugas: tugasList));
      } else if(response.statusCode == 404){
        emit(TugasLoaded(tugas: []));
      }
      else {
        emit(TugasError(message: 'Failed to load tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TugasError(message: 'Error fetching tugas: $e'));
    }
  }

  Future<void> _onFetchTugasByIdUser(FetchTugasByIdUser event, Emitter<TugasState> emit) async {
    emit(TugasLoading());

    final url = Uri.parse('$baseUrl/api/tugas/user/${event.id_user}');

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

        final List<TugasModel> tugasList = data.map((json) => TugasModel.fromJson(json))
            .toList();

        emit(TugasLoaded(tugas: tugasList));
      }
      else {
        emit(TugasError(message: 'Failed to load tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TugasError(message: 'Error fetching tugas: $e'));
    }
  }

  Future<void> _onCreateTugas(CreateTugas event, Emitter<TugasState> emit) async {
    emit(TugasLoading());

    final url = Uri.parse('$baseUrl/api/tugas');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_user': event.idUser,
          'id_mapel': event.idMapel,
          'nama': event.nama,
          'deskripsi': event.deskripsi,
          'kelas': event.kelas,
          'link_video': event.linkVideo,
          'link_gambar': event.linkGambar,
          'link_audio': event.linkAudio,
          'link_file': event.linkFile,
          'deadline': event.deadline.toIso8601String(),
          'id_tahun_pelajaran': event.id_tahun_pelajaran,
        }),
      );

      if (response.statusCode == 201) {
        emit(TugasInitial());
      } else {
        final errorData = json.decode(response.body);
        emit(TugasError(message: 'Failed to create tugas: ${errorData['message']}'));
      }
    } catch (e) {
      emit(TugasError(message: 'Error creating tugas: $e'));
    }
  }

  Future<void> _onUpdateTugas(UpdateTugas event, Emitter<TugasState> emit) async {
    emit(TugasLoading());

    final url = Uri.parse('$baseUrl/api/tugas/${event.tugasId}');

    try {
      final Map<String, dynamic> updateData = {
        'nama': event.nama,
        'deskripsi': event.deskripsi,
        'kelas': event.kelas,
        'link_video': event.linkVideo,
        'link_gambar': event.linkGambar,
        'link_audio': event.linkAudio,
        'link_file': event.linkFile,
        'deadline': event.deadline.toIso8601String(),
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        emit(TugasInitial());
      } else {
        final errorData = json.decode(response.body);
        emit(TugasError(message: 'Failed to update tugas: ${errorData['message']}'));
      }
    } catch (e) {
      emit(TugasError(message: 'Error updating tugas: $e'));
    }
  }

  Future<void> _onDeleteTugas(DeleteTugas event, Emitter<TugasState> emit) async {
    emit(TugasLoading());

    final url = Uri.parse('$baseUrl/api/tugas/${event.tugasId}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        emit(TugasInitial());
      } else {
        final errorData = json.decode(response.body);
        emit(TugasError(message: 'Failed to delete tugas: ${errorData['message']}'));
      }
    } catch (e) {
      emit(TugasError(message: 'Error deleting tugas: $e'));
    }
  }
}