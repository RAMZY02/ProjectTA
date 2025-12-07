import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/tahun_pelajaran_model.dart'; // Ganti dengan model yang sesuai
import 'tahun_pelajaran_event.dart';
import 'tahun_pelajaran_state.dart';

class TahunPelajaranBloc extends Bloc<TahunPelajaranEvent, TahunPelajaranState> {

  final String baseUrl = 'http://localhost:3000/api/tahun-pelajaran';
  // final String baseUrl = 'https://flounder-moved-rooster.ngrok-free.app/api/tahun-pelajaran';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud/api/tahun-pelajaran';

  TahunPelajaranBloc() : super(TahunPelajaranInitial()) {
    on<FetchAllTahunPelajaran>(_onFetchAllTahunPelajaran);
    on<FetchTahunPelajaranById>(_onFetchTahunPelajaranById);
    on<CreateTahunPelajaran>(_onCreateTahunPelajaran);
    on<UpdateTahunPelajaran>(_onUpdateTahunPelajaran);
    on<DeleteTahunPelajaran>(_onDeleteTahunPelajaran);
  }

  Future<void> _onFetchAllTahunPelajaran(
      FetchAllTahunPelajaran event, Emitter<TahunPelajaranState> emit) async {
    emit(TahunPelajaranLoading());

    final url = Uri.parse(baseUrl);

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
          final tahunPelajaranList = (data['data'] as List)
              .map((item) => TahunPelajaranModel.fromJson(item))
              .toList();
          emit(TahunPelajaranLoaded(tahunPelajaranList));
        } else {
          emit(TahunPelajaranError(data['message'] ?? 'Failed to fetch tahun pelajaran'));
        }
      } else {
        emit(TahunPelajaranError(
            'Failed to fetch tahun pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TahunPelajaranError('Error fetching tahun pelajaran: $e'));
    }
  }

  Future<void> _onFetchTahunPelajaranById(
      FetchTahunPelajaranById event, Emitter<TahunPelajaranState> emit) async {
    emit(TahunPelajaranLoading());

    final url = Uri.parse('$baseUrl/${event.id}');

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
          final tahunPelajaran = TahunPelajaranModel.fromJson(data['data']);
          emit(TahunPelajaranDetailLoaded(tahunPelajaran));
        } else {
          emit(TahunPelajaranError(data['message'] ?? 'Tahun pelajaran not found'));
        }
      } else {
        emit(TahunPelajaranError(
            'Failed to fetch tahun pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TahunPelajaranError('Error fetching tahun pelajaran: $e'));
    }
  }

  Future<void> _onCreateTahunPelajaran(
      CreateTahunPelajaran event, Emitter<TahunPelajaranState> emit) async {
    emit(TahunPelajaranLoading());

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'tahun': event.tahun,
          'semester': event.semester,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final tahunPelajaran = TahunPelajaranModel.fromJson(data['data']);
          emit(TahunPelajaranCreated(tahunPelajaran));
          // Refresh data setelah create
          add(FetchAllTahunPelajaran(token: event.token));
        } else {
          emit(TahunPelajaranError(data['message'] ?? 'Failed to create tahun pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(TahunPelajaranError(
            errorData['message'] ?? 'Failed to create tahun pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TahunPelajaranError('Error creating tahun pelajaran: $e'));
    }
  }

  Future<void> _onUpdateTahunPelajaran(
      UpdateTahunPelajaran event, Emitter<TahunPelajaranState> emit) async {
    emit(TahunPelajaranLoading());

    final url = Uri.parse('$baseUrl/${event.id}');

    try {
      final body = {};
      if (event.tahun != null) body['tahun'] = event.tahun;
      if (event.semester != null) body['semester'] = event.semester;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode(body),
      );

      final respStr = response.body;

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final tahunPelajaran = TahunPelajaranModel.fromJson(data['data']);
          emit(TahunPelajaranUpdated(tahunPelajaran));
          // Refresh data setelah update
          add(FetchAllTahunPelajaran(token: event.token));
        } else {
          emit(TahunPelajaranError(data['message'] ?? 'Failed to update tahun pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(TahunPelajaranError(
            errorData['message'] ?? 'Failed to update tahun pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TahunPelajaranError('Error updating tahun pelajaran: $e'));
    }
  }

  Future<void> _onDeleteTahunPelajaran(
      DeleteTahunPelajaran event, Emitter<TahunPelajaranState> emit) async {
    emit(TahunPelajaranLoading());

    final url = Uri.parse('$baseUrl/${event.id}');

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
          emit(TahunPelajaranDeleted(event.id));
          // Refresh data setelah delete
          add(FetchAllTahunPelajaran(token: event.token));
        } else {
          emit(TahunPelajaranError(data['message'] ?? 'Failed to delete tahun pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(TahunPelajaranError(
            errorData['message'] ?? 'Failed to delete tahun pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TahunPelajaranError('Error deleting tahun pelajaran: $e'));
    }
  }
}