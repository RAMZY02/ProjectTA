import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/kelas_mengajar_model.dart'; // Pastikan model sesuai
import 'kelas_mengajar_event.dart';
import 'kelas_mengajar_state.dart';

class KelasMengajarBloc extends Bloc<KelasMengajarEvent, KelasMengajarState> {

  // final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  KelasMengajarBloc() : super(KelasMengajarInitial()) {
    on<FetchAllKelasMengajar>(_onFetchAllKelasMengajar);
    on<FetchKelasMengajarById>(_onFetchKelasMengajarById);
    on<FetchKelasMengajarByUserId>(_onFetchKelasMengajarByUserId);
    on<CreateKelasMengajar>(_onCreateKelasMengajar);
    on<UpdateKelasMengajar>(_onUpdateKelasMengajar);
    on<DeleteKelasMengajar>(_onDeleteKelasMengajar);
  }

  Future<void> _onFetchAllKelasMengajar(
      FetchAllKelasMengajar event, Emitter<KelasMengajarState> emit) async {
    emit(KelasMengajarLoading());

    final url = Uri.parse(
        '$baseUrl/api/kelas-mengajar');

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
          final kelasMengajarList = (data['data'] as List)
              .map((item) => KelasMengajarModel.fromJson(item))
              .toList();
          emit(KelasMengajarLoaded(kelasMengajarList));
        } else {
          emit(KelasMengajarError(data['message'] ?? 'Failed to fetch kelas mengajar'));
        }
      } else {
        emit(KelasMengajarError(
            'Failed to fetch kelas mengajar: ${response.statusCode}'));
      }
    } catch (e) {
      emit(KelasMengajarError('Error fetching kelas mengajar: $e'));
    }
  }

  Future<void> _onFetchKelasMengajarById(
      FetchKelasMengajarById event, Emitter<KelasMengajarState> emit) async {
    emit(KelasMengajarLoading());

    final url = Uri.parse(
        '$baseUrl/api/kelas-mengajar/${event.id}');

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
          final kelasMengajar = KelasMengajarModel.fromJson(data['data']);
          emit(KelasMengajarDetailLoaded(kelasMengajar));
        } else {
          emit(KelasMengajarError(data['message'] ?? 'Kelas mengajar not found'));
        }
      } else {
        emit(KelasMengajarError(
            'Failed to fetch kelas mengajar: ${response.statusCode}'));
      }
    } catch (e) {
      emit(KelasMengajarError('Error fetching kelas mengajar: $e'));
    }
  }

  Future<void> _onFetchKelasMengajarByUserId(
      FetchKelasMengajarByUserId event, Emitter<KelasMengajarState> emit) async {
    emit(KelasMengajarLoading());

    final url = Uri.parse(
        '$baseUrl/api/kelas-mengajar/${event.idUser}');

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
          final kelasMengajarList = (data['data'] as List)
              .map((item) => KelasMengajarModel.fromJson(item))
              .toList();
          emit(KelasMengajarByUserIdLoaded(kelasMengajarList));
        } else {
          emit(KelasMengajarError(data['message'] ?? 'No kelas mengajar found for this user'));
        }
      } else {
        emit(KelasMengajarError(
            'Failed to fetch kelas mengajar by user ID: ${response.statusCode}'));
      }
    } catch (e) {
      emit(KelasMengajarError('Error fetching kelas mengajar by user ID: $e'));
    }
  }

  Future<void> _onCreateKelasMengajar(
      CreateKelasMengajar event, Emitter<KelasMengajarState> emit) async {
    emit(KelasMengajarLoading());

    final url = Uri.parse(
        '$baseUrl/api/kelas-mengajar');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_user': event.idUser,
          'kelas': event.kelas,
          'key_status': event.keyStatus ?? 'active',
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final kelasMengajar = KelasMengajarModel.fromJson(data['data']);
          emit(KelasMengajarCreated(kelasMengajar));
          // Refresh data setelah create
          add(FetchAllKelasMengajar(token: event.token));
        } else {
          emit(KelasMengajarError(data['message'] ?? 'Failed to create kelas mengajar'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(KelasMengajarError(
            errorData['message'] ?? 'Failed to create kelas mengajar: ${response.statusCode}'));
      }
    } catch (e) {
      emit(KelasMengajarError('Error creating kelas mengajar: $e'));
    }
  }

  Future<void> _onUpdateKelasMengajar(
      UpdateKelasMengajar event, Emitter<KelasMengajarState> emit) async {
    emit(KelasMengajarLoading());

    final url = Uri.parse(
        '$baseUrl/api/kelas-mengajar/${event.id}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_user': event.idUser,
          'kelas': event.kelas,
          'key_status': event.keyStatus,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final kelasMengajar = KelasMengajarModel.fromJson(data['data']);
          emit(KelasMengajarUpdated(kelasMengajar));
          // Refresh data setelah update
          add(FetchAllKelasMengajar(token: event.token));
        } else {
          emit(KelasMengajarError(data['message'] ?? 'Failed to update kelas mengajar'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(KelasMengajarError(
            errorData['message'] ?? 'Failed to update kelas mengajar: ${response.statusCode}'));
      }
    } catch (e) {
      emit(KelasMengajarError('Error updating kelas mengajar: $e'));
    }
  }

  Future<void> _onDeleteKelasMengajar(
      DeleteKelasMengajar event, Emitter<KelasMengajarState> emit) async {
    emit(KelasMengajarLoading());

    final url = Uri.parse(
        '$baseUrl/api/kelas-mengajar/${event.id}');

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
          emit(KelasMengajarDeleted(event.id));
          // Refresh data setelah delete
          add(FetchAllKelasMengajar(token: event.token));
        } else {
          emit(KelasMengajarError(data['message'] ?? 'Failed to delete kelas mengajar'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(KelasMengajarError(
            errorData['message'] ?? 'Failed to delete kelas mengajar: ${response.statusCode}'));
      }
    } catch (e) {
      emit(KelasMengajarError('Error deleting kelas mengajar: $e'));
    }
  }
}