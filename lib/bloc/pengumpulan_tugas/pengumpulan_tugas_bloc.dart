import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/pengumpulan_tugas_model.dart';
import 'pengumpulan_tugas_event.dart';
import 'pengumpulan_tugas_state.dart';

class PengumpulanTugasBloc extends Bloc<PengumpulanTugasEvent, PengumpulanTugasState> {

  final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  PengumpulanTugasBloc() : super(PengumpulanTugasInitial()) {
    on<FetchPengumpulanTugas>(_onFetchPengumpulanTugas);
    on<FetchPengumpulanByTugas>(_onFetchPengumpulanByTugas);
    on<SubmitPengumpulanTugas>(_onSubmitPengumpulanTugas);
    on<UpdatePengumpulanNilai>(_onUpdatePengumpulanNilai);
  }

  Future<void> _onFetchPengumpulanTugas(
      FetchPengumpulanTugas event, Emitter<PengumpulanTugasState> emit) async {
    emit(PengumpulanTugasLoading());

    final url = Uri.parse(
        '$baseUrl/api/pengumpulan-tugas/${event.idUser}/${event.idTugas}');

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
        emit(PengumpulanTugasLoaded(data['data']));
      } else {
        emit(PengumpulanTugasError(
            'Failed to fetch pengumpulan tugas: ${response.statusCode}'));
      }
    } catch (e) {
      emit(PengumpulanTugasError('Error fetching pengumpulan tugas: $e'));
    }
  }

  // pengumpulan_tugas_bloc.dart
  Future<void> _onFetchPengumpulanByTugas(
      FetchPengumpulanByTugas event,
      Emitter<PengumpulanTugasState> emit) async {
    emit(PengumpulanTugasLoading());
    try {
      final url = Uri.parse("$baseUrl/api/pengumpulan-tugas/tugas/${event.idTugas}");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${event.token}',
      });

      final List<dynamic> data = json.decode(response.body);
      print("ini data nya");
      print(data);

      if (response.statusCode == 200) {
        final pengumpulTugas = data.map((pengumpul) => PengumpulanTugasModel.fromJson(pengumpul)).toList();
        emit(PengumpulanTugasLoaded(pengumpulTugas));
      } else {
        emit(PengumpulanTugasError("Failed load pengumpulan"));
      }
    } catch (e) {
      emit(PengumpulanTugasError("Error: $e"));
    }
  }

  Future<void> _onSubmitPengumpulanTugas(
      SubmitPengumpulanTugas event,
      Emitter<PengumpulanTugasState> emit,
      ) async {
    emit(PengumpulanTugasLoading());

    final url = Uri.parse(
      '$baseUrl/api/pengumpulan-tugas',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id_user": event.idUser,
          "id_tugas": event.idTugas,
          "deskripsi": event.deskripsi.isNotEmpty ? event.deskripsi : "-",
          "link_gambar": event.gambarPath ?? "-",
          "link_video": event.videoPath ?? "-",
          "link_audio": event.audioPath ?? "-",
          "link_file": event.filePath ?? "-",
        }),
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        emit(PengumpulanTugasSuccess(data));
      } else {
        final errorData = jsonDecode(respStr);
        emit(
          PengumpulanTugasError(
            'Failed to submit tugas: ${errorData['message'] ?? 'Unknown error'}',
          ),
        );
      }
    } catch (e) {
      emit(PengumpulanTugasError('Error submitting pengumpulan tugas: $e'));
    }
  }

  Future<void> _onUpdatePengumpulanNilai(
      UpdatePengumpulanNilai event,
      Emitter<PengumpulanTugasState> emit,
      ) async {
    emit(PengumpulanTugasLoading());

    final url = Uri.parse(
      '$baseUrl/api/pengumpulan-tugas/nilai/${event.id}/${event.nilai}',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
      );

      final respStr = response.body;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(respStr);
        emit(PengumpulanTugasSuccess(data));
      } else {
        final errorData = jsonDecode(respStr);
        emit(
          PengumpulanTugasError(
            'Failed to submit tugas: ${errorData['message'] ?? 'Unknown error'}',
          ),
        );
      }
    } catch (e) {
      emit(PengumpulanTugasError('Error submitting pengumpulan tugas: $e'));
    }
  }

}
