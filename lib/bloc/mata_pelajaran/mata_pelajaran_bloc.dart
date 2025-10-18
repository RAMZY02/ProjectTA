import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/mata_pelajaran_model.dart'; // Pastikan model sesuai
import 'mata_pelajaran_event.dart';
import 'mata_pelajaran_state.dart';

class MataPelajaranBloc extends Bloc<MataPelajaranEvent, MataPelajaranState> {

  // final String baseUrl = 'http://localhost:3000/api/mata-pelajaran';
  final String baseUrl = 'https://flounder-moved-rooster.ngrok-free.app/api/mata-pelajaran';

  MataPelajaranBloc() : super(MataPelajaranInitial()) {
    on<InitialMataPelajaran>(_onInitialMataPelajaran);
    on<FetchAllMataPelajaran>(_onFetchAllMataPelajaran);
    on<FetchMataPelajaranById>(_onFetchMataPelajaranById);
    on<FetchMataPelajaranSiswa>(_onFetchMataPelajaranSiswa);
    on<CreateMataPelajaran>(_onCreateMataPelajaran);
    on<UpdateMataPelajaran>(_onUpdateMataPelajaran);
    on<DeleteMataPelajaran>(_onDeleteMataPelajaran);
    on<RestoreMataPelajaran>(_onRestoreMataPelajaran);
  }

  Future<void> _onInitialMataPelajaran(InitialMataPelajaran event, Emitter<MataPelajaranState> emit) async{
    emit(MataPelajaranInitial());
  }

  Future<void> _onFetchAllMataPelajaran(
      FetchAllMataPelajaran event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

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
          final mataPelajaranList = (data['data'] as List)
              .map((item) => MataPelajaranModel.fromJson(item))
              .toList();
          emit(MataPelajaranLoaded(mataPelajaranList));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Failed to fetch mata pelajaran'));
        }
      } else {
        emit(MataPelajaranError(
            'Failed to fetch mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error fetching mata pelajaran: $e'));
    }
  }

  Future<void> _onFetchMataPelajaranById(
      FetchMataPelajaranById event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

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
          final mataPelajaran = MataPelajaranModel.fromJson(data['data']);
          emit(MataPelajaranDetailLoaded(mataPelajaran));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Mata pelajaran not found'));
        }
      } else {
        emit(MataPelajaranError(
            'Failed to fetch mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error fetching mata pelajaran: $e'));
    }
  }

  Future<void> _onFetchMataPelajaranSiswa(
      FetchMataPelajaranSiswa event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

    final url = Uri.parse('$baseUrl/siswa/${event.id_user}');

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
          final mataPelajaran = (data['data'] as List)
              .map((item) => MataPelajaranModel.fromJson(item))
              .toList();
          emit(MataPelajaranLoaded(mataPelajaran));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Mata pelajaran not found'));
        }
      } else {
        emit(MataPelajaranError(
            'Failed to fetch mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error fetching mata pelajaran: $e'));
    }
  }

  Future<void> _onCreateMataPelajaran(
      CreateMataPelajaran event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'mapel': event.mapel,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final mataPelajaran = MataPelajaranModel.fromJson(data['data']);
          emit(MataPelajaranCreated(mataPelajaran));
          // Refresh data setelah create
          add(FetchAllMataPelajaran(token: event.token));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Failed to create mata pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(MataPelajaranError(
            errorData['message'] ?? 'Failed to create mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error creating mata pelajaran: $e'));
    }
  }

  Future<void> _onUpdateMataPelajaran(
      UpdateMataPelajaran event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

    final url = Uri.parse('$baseUrl/${event.id}');

    try {
      final body = {};
      if (event.mapel != null) body['mapel'] = event.mapel;
      if (event.keyStatus != null) body['key_status'] = event.keyStatus;

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
          final mataPelajaran = MataPelajaranModel.fromJson(data['data']);
          emit(MataPelajaranUpdated(mataPelajaran));
          // Refresh data setelah update
          add(FetchAllMataPelajaran(token: event.token));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Failed to update mata pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(MataPelajaranError(
            errorData['message'] ?? 'Failed to update mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error updating mata pelajaran: $e'));
    }
  }

  Future<void> _onDeleteMataPelajaran(
      DeleteMataPelajaran event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

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
          emit(MataPelajaranDeleted(event.id));
          // Refresh data setelah delete
          add(FetchAllMataPelajaran(token: event.token));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Failed to delete mata pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(MataPelajaranError(
            errorData['message'] ?? 'Failed to delete mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error deleting mata pelajaran: $e'));
    }
  }

  Future<void> _onRestoreMataPelajaran(
      RestoreMataPelajaran event, Emitter<MataPelajaranState> emit) async {
    emit(MataPelajaranLoading());

    final url = Uri.parse('$baseUrl/${event.id}/restore');

    try {
      final response = await http.post(
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
          emit(MataPelajaranRestored(event.id));
          // Refresh data setelah restore
          add(FetchAllMataPelajaran(token: event.token));
        } else {
          emit(MataPelajaranError(data['message'] ?? 'Failed to restore mata pelajaran'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(MataPelajaranError(
            errorData['message'] ?? 'Failed to restore mata pelajaran: ${response.statusCode}'));
      }
    } catch (e) {
      emit(MataPelajaranError('Error restoring mata pelajaran: $e'));
    }
  }
}