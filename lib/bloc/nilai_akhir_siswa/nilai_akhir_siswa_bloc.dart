import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/models/mata_pelajaran_model.dart';
import 'package:project_ta/models/nilai_akhir_wali_kelas_model.dart';
import '../../models/nilai_akhir_siswa_model.dart'; // Pastikan model sesuai
import 'nilai_akhir_siswa_event.dart';
import 'nilai_akhir_siswa_state.dart';

class NilaiAkhirSiswaBloc extends Bloc<NilaiAkhirSiswaEvent, NilaiAkhirSiswaState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  NilaiAkhirSiswaBloc() : super(NilaiAkhirSiswaInitial()) {
    on<InitNilaiAkhirSiswa>(_onInit);
    on<FetchAllNilaiAkhirSiswa>(_onFetchAllNilaiAkhirSiswa);
    on<FetchNilaiAkhirSiswaById>(_onFetchNilaiAkhirSiswaById);
    on<FetchNilaiAkhirSiswaByMapelAndKelas>(_onFetchNilaiAkhirSiswaByMapelAndKelas);
    on<FetchRapotWaliKelas>(_onFetchRapotWaliKelas);
    on<CreateNilaiAkhirSiswa>(_onCreateNilaiAkhirSiswa);
    on<CreateAllNilaiAkhirSiswa>(_onCreateAllNilaiAkhirSiswa);
    on<CreateOrUpdateNilaiAkhirSiswa>(_onCreateOrUpdateNilaiAkhirSiswa);
    on<UpdateNilaiAkhirSiswa>(_onUpdateNilaiAkhirSiswa);
    on<DeleteNilaiAkhirSiswa>(_onDeleteNilaiAkhirSiswa);
  }

  Future<void> _onInit(InitNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaInitial());
  }

  Future<void> _onFetchAllNilaiAkhirSiswa(
      FetchAllNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa');

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
          final nilaiAkhirList = (data['data'] as List)
              .map((item) => NilaiAkhirSiswaModel.fromJson(item))
              .toList();
          emit(NilaiAkhirSiswaLoaded(nilaiAkhirList));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Failed to fetch nilai akhir siswa'));
        }
      } else {
        emit(NilaiAkhirSiswaError(
            'Failed to fetch nilai akhir siswa: belum ada data '));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error fetching nilai akhir siswa: $e'));
    }
  }

  Future<void> _onFetchNilaiAkhirSiswaById(
      FetchNilaiAkhirSiswaById event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/${event.id}');

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
          final nilaiAkhir = NilaiAkhirSiswaModel.fromJson(data['data']);
          emit(NilaiAkhirSiswaDetailLoaded(nilaiAkhir));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Nilai akhir siswa not found'));
        }
      } else {
        emit(NilaiAkhirSiswaError(
            'Failed to fetch nilai akhir siswa: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error fetching nilai akhir siswa: $e'));
    }
  }

  // Di nilai_akhir_siswa_bloc.dart
  Future<void> _onFetchNilaiAkhirSiswaByMapelAndKelas(
      FetchNilaiAkhirSiswaByMapelAndKelas event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/mapel/${event.id_mapel}/kelas/${event.kelas}');

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
          final nilaiAkhirList = (data['data'] as List)
              .map((item) => NilaiAkhirSiswaModel.fromJson(item))
              .toList();
          emit(NilaiAkhirSiswaLoaded(nilaiAkhirList));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Nilai akhir not found'));
        }
      } else {
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error fetching nilai akhir: $e'));
    }
  }

  Future<void> _onFetchRapotWaliKelas(
      FetchRapotWaliKelas event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/rapot-wali-kelas/${event.kelas}');

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
          final nilaiAkhirList = (data['data'] as List)
              .map((item) => NilaiAkhirWaliKelasModel.fromJson(item))
              .toList();
          final mapelData = (data['mapelList'] as List).map((item) => MataPelajaranModel.fromJson(item)).toList();
          emit(NilaiAkhirWaliKelasLoaded(nilaiAkhirList, mapelData, data['siswa'] as int, data['siswaIslam'] as int, data['siswaHindu'] as int, data['siswaKristen'] as int, data['siswaKatolik'] as int));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Nilai akhir not found'));
        }
      } else {
        emit(NilaiAkhirSiswaError(
            'Failed to fetch nilai akhir: belum ada data '));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error fetching nilai akhir: $e'));
    }
  }

  Future<void> _onCreateNilaiAkhirSiswa(
      CreateNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa');

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
          'nilai_akhir': event.nilaiAkhir,
          'capaian_kompetensi': event.capaian_kompetensi,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final nilaiAkhir = NilaiAkhirSiswaModel.fromJson(data['data']);
          emit(NilaiAkhirSiswaCreated(nilaiAkhir));
          // Refresh data setelah create
          add(FetchAllNilaiAkhirSiswa(token: event.token));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Failed to create nilai akhir siswa'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(NilaiAkhirSiswaError(
            errorData['message'] ?? 'Failed to create nilai akhir siswa: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error creating nilai akhir siswa: $e'));
    }
  }

  Future<void> _onCreateOrUpdateNilaiAkhirSiswa(
      CreateOrUpdateNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/createorupdate');

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
          'nilai_akhir': event.nilaiAkhir,
          'capaian_kompetensi': event.capaian_kompetensi,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          // Refresh data setelah create
          add(FetchNilaiAkhirSiswaByMapelAndKelas(token: event.token, id_mapel: event.id_mapel, kelas: event.kelas));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Failed to create nilai akhir siswa'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(NilaiAkhirSiswaError(
            errorData['message'] ?? 'Failed to create nilai akhir siswa: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error creating nilai akhir siswa: $e'));
    }
  }

  Future<void> _onCreateAllNilaiAkhirSiswa(
      CreateAllNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/bulk');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'nilai_akhir_list': event.nilaiAkhirList,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          emit(NilaiAkhirSiswaSuccess(data['message'] ?? 'Nilai akhir berhasil disimpan'));
          // Refresh data setelah create massal
          add(FetchAllNilaiAkhirSiswa(token: event.token));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Failed to create nilai akhir siswa'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(NilaiAkhirSiswaError(
            errorData['message'] ?? 'Failed to create nilai akhir siswa: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error creating nilai akhir siswa: $e'));
    }
  }

  Future<void> _onUpdateNilaiAkhirSiswa(
      UpdateNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/${event.id}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_user': event.idUser,
          'mapel': event.mapel,
          'kelas': event.kelas,
          'nilai_akhir': event.nilaiAkhir,
          'capaian_kompetensi': event.capaian_kompetensi,
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        if (data['success'] == true) {
          final nilaiAkhir = NilaiAkhirSiswaModel.fromJson(data['data']);
          emit(NilaiAkhirSiswaUpdated(nilaiAkhir));
          // Refresh data setelah update
          add(FetchAllNilaiAkhirSiswa(token: event.token));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Failed to update nilai akhir siswa'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(NilaiAkhirSiswaError(
            errorData['message'] ?? 'Failed to update nilai akhir siswa: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error updating nilai akhir siswa: $e'));
    }
  }

  Future<void> _onDeleteNilaiAkhirSiswa(
      DeleteNilaiAkhirSiswa event, Emitter<NilaiAkhirSiswaState> emit) async {
    emit(NilaiAkhirSiswaLoading());

    final url = Uri.parse(
        '$baseUrl/api/nilai-akhir-siswa/${event.id}');

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
          emit(NilaiAkhirSiswaDeleted(event.id));
          // Refresh data setelah delete
          add(FetchAllNilaiAkhirSiswa(token: event.token));
        } else {
          emit(NilaiAkhirSiswaError(data['message'] ?? 'Failed to delete nilai akhir siswa'));
        }
      } else {
        final errorData = jsonDecode(respStr);
        emit(NilaiAkhirSiswaError(
            errorData['message'] ?? 'Failed to delete nilai akhir siswa: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NilaiAkhirSiswaError('Error deleting nilai akhir siswa: $e'));
    }
  }
}