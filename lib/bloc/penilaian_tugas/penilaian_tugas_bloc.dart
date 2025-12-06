import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/penilaian_tugas_model.dart'; // Pastikan model sesuai
import 'penilaian_tugas_event.dart';
import 'penilaian_tugas_state.dart';

class PenilaianTugasBloc extends Bloc<PenilaianTugasEvent, PenilaianTugasState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  PenilaianTugasBloc() : super(PenilaianTugasInitial()) {
    on<FetchAllPenilaianTugas>(_onFetchAllPenilaianTugas);
    on<FetchPenilaianTugasById>(_onFetchPenilaianTugasById);
    on<CreatePenilaianTugas>(_onCreatePenilaianTugas);
    on<UpdatePenilaianTugas>(_onUpdatePenilaianTugas);
    on<DeletePenilaianTugas>(_onDeletePenilaianTugas);
  }

  Future<void> _onFetchAllPenilaianTugas(
      FetchAllPenilaianTugas event, Emitter<PenilaianTugasState> emit) async {
    emit(PenilaianTugasLoading());

    final url = Uri.parse(
        '$baseUrl/api/penilaian-tugas');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final penilaianList = (data['data'] as List)
              .map((item) => PenilaianTugasModel.fromJson(item))
              .toList();
          emit(PenilaianTugasLoaded(penilaianList));
        } else {
          emit(PenilaianTugasError(data['message'] ?? 'Failed to fetch penilaian tugas'));
        }
      } else {
        emit(PenilaianTugasError(
            'Failed to fetch penilaian tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PenilaianTugasError('Error fetching penilaian tugas: $e'));
    }
  }

  Future<void> _onFetchPenilaianTugasById(
      FetchPenilaianTugasById event, Emitter<PenilaianTugasState> emit) async {
    emit(PenilaianTugasLoading());

    final url = Uri.parse(
        '$baseUrl/api/penilaian-tugas/${event.id}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final penilaian = PenilaianTugasModel.fromJson(data['data']);
          emit(PenilaianTugasDetailLoaded(penilaian));
        } else {
          emit(PenilaianTugasError(data['message'] ?? 'Penilaian tugas not found'));
        }
      } else {
        emit(PenilaianTugasError(
            'Failed to fetch penilaian tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PenilaianTugasError('Error fetching penilaian tugas: $e'));
    }
  }

  Future<void> _onCreatePenilaianTugas(
      CreatePenilaianTugas event, Emitter<PenilaianTugasState> emit) async {
    emit(PenilaianTugasLoading());

    final url = Uri.parse(
        '$baseUrl/api/penilaian-tugas');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_user': event.idUser,
          'id_mapel': event.id_mapel,
          'kelas': event.kelas,
          'kolom': event.kolom,
          'nilai': event.nilai,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        final penilaian = PenilaianTugasModel.fromJson(data['data']);
        emit(PenilaianTugasCreated(penilaian));
        // Refresh data setelah create
        add(FetchAllPenilaianTugas(token: event.token));
      } else {
        final errorData = jsonDecode(respStr);
        emit(PenilaianTugasError(
            errorData['message'] ?? 'Failed to create penilaian tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PenilaianTugasError('Error creating penilaian tugas: $e'));
    }
  }

  Future<void> _onUpdatePenilaianTugas(
      UpdatePenilaianTugas event, Emitter<PenilaianTugasState> emit) async {
    emit(PenilaianTugasLoading());

    final url = Uri.parse(
        '$baseUrl/api/penilaian-tugas/${event.id}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_user': event.idUser,
          'nilai': event.nilai,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final penilaian = PenilaianTugasModel.fromJson(data['data']);
          emit(PenilaianTugasUpdated(penilaian));
          // Refresh data setelah update
          add(FetchAllPenilaianTugas(token: event.token));
        } else {
          emit(PenilaianTugasError(data['message'] ?? 'Failed to update penilaian tugas'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(PenilaianTugasError(
            errorData['message'] ?? 'Failed to update penilaian tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PenilaianTugasError('Error updating penilaian tugas: $e'));
    }
  }

  Future<void> _onDeletePenilaianTugas(
      DeletePenilaianTugas event, Emitter<PenilaianTugasState> emit) async {
    emit(PenilaianTugasLoading());

    final url = Uri.parse(
        '$baseUrl/api/penilaian-tugas/${event.id}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final respStr = response.body;

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          emit(PenilaianTugasDeleted(event.id));
          // Refresh data setelah delete
          add(FetchAllPenilaianTugas(token: event.token));
        } else {
          emit(PenilaianTugasError(data['message'] ?? 'Failed to delete penilaian tugas'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(PenilaianTugasError(
            errorData['message'] ?? 'Failed to delete penilaian tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PenilaianTugasError('Error deleting penilaian tugas: $e'));
    }
  }
}