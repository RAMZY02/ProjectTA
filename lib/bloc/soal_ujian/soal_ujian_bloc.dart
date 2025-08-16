// bloc/soal_ujian/soal_ujian_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/models/soal_model.dart';

class SoalUjianBloc extends Bloc<SoalUjianEvent, SoalUjianState> {
  SoalUjianBloc() : super(SoalUjianInitial()) {
    on<InitSoalUjian>(_onInit);
    on<FetchSoalUjian>(_onFetchSoalUjian);
    on<FetchSoalUjian2>(_onFetchSoalUjian2);
    on<FetchSoalUjian3>(_onFetchSoalUjian3);
    on<AddSoal>(_onAddSoal);
    on<UpdateSoal>(_onUpdateSoal);
    on<DeleteSoal>(_onDeleteSoal);
  }

  Future<void> _onFetchSoalUjian(
    FetchSoalUjian event,
    Emitter<SoalUjianState> emit,
  ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal/${event.ujianId}/${event.userId}');
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
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      }
      else if(response.statusCode == 404){
        emit(SoalUjianNotFound(message: "Belum Ada Soal Yang Terdaftar!"));
      }
      else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchSoalUjian2(
    FetchSoalUjian2 event,
    Emitter<SoalUjianState> emit,
  ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal/${event.ujianId}');
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
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      }
      else if(response.statusCode == 404){
        emit(SoalUjianNotFound(message: "Belum Ada Soal Yang Terdaftar!"));
      }
      else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchSoalUjian3(
      FetchSoalUjian3 event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal/urutan/${event.ujianId}/${event.userId}');
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
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      }
      else if(response.statusCode == 404){
        emit(SoalUjianNotFound(message: "Belum Ada Soal Yang Terdaftar!"));
      }
      else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onInit(InitSoalUjian event, Emitter<SoalUjianState> emit) async {
    emit(SoalUjianInitial());
  }

  Future<void> _onAddSoal(
      AddSoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_ujian': event.soalData['id_ujian'],
          'tipe': event.soalData['tipe'],
          'soal': event.soalData['soal'],
          'opsi_a': event.soalData['opsi_a'],
          'opsi_b': event.soalData['opsi_b'],
          'opsi_c': event.soalData['opsi_c'],
          'opsi_d': event.soalData['opsi_d'],
          'opsi_e': event.soalData['opsi_e'],
          'jawaban': event.soalData['jawaban'],
          'pembahasan': event.soalData['pembahasan'],
          'link_video': event.soalData['link_video'],
          'link_gambar': event.soalData['link_gambar'],
          'link_file': event.soalData['link_file'],
          'link_audio': event.soalData['link_audio'],
        })
      );

      if (response.statusCode == 201) {
        add(FetchSoalUjian2(token: event.token, ujianId: int.parse(event.soalData['id_ujian'].toString())));
      }
      else {
        emit(SoalUjianError(message: 'Gagal add soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateSoal(
      UpdateSoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal/${event.soalData['id']}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_ujian': event.soalData['id_ujian'],
          'tipe': event.soalData['tipe'],
          'soal': event.soalData['soal'],
          'opsi_a': event.soalData['opsi_a'],
          'opsi_b': event.soalData['opsi_b'],
          'opsi_c': event.soalData['opsi_c'],
          'opsi_d': event.soalData['opsi_d'],
          'opsi_e': event.soalData['opsi_e'],
          'jawaban': event.soalData['jawaban'],
          'pembahasan': event.soalData['pembahasan'],
          'link_video': event.soalData['link_video'],
          'link_gambar': event.soalData['link_gambar'],
          'link_file': event.soalData['link_file'],
          'link_audio': event.soalData['link_audio'],
        })
      );

      if (response.statusCode == 200) {
        add(FetchSoalUjian2(token: event.token, ujianId: int.parse(event.soalData['id_ujian'].toString())));
      } else {
        emit(SoalUjianError(message: 'Gagal add soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteSoal(
      DeleteSoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/soal/delete/${event.id}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_ujian' : event.id_ujian
        })
      );

      if (response.statusCode == 200) {
        add(FetchSoalUjian2(token: event.token, ujianId: event.id));
      } else {
        emit(SoalUjianError(message: 'Gagal add soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }
}
