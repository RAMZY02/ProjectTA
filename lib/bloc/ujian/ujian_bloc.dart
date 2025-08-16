// bloc/ujian/ujian_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';

class UjianBloc extends Bloc<UjianEvent, UjianState> {
  UjianBloc() : super(UjianInitial()) {
    on<InitUjian>(_onInitUjian);
    on<FetchUjian>(_onFetchUjian);
    on<FetchUjian2>(_onFetchUjian2);
    on<AddUjian>(_onAddUjian);
    on<UpdateUjian>(_onUpdateUjian);
    on<DeleteUjian>(_onDeleteUjian);
  }

  Future<void> _onInitUjian(InitUjian event, Emitter<UjianState> emit) async {
    emit(UjianInitial());
  }

  Future<void> _onFetchUjian(FetchUjian event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/ujian/belum-selesai');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final List<dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        final ujianList = data.map((ujian) => UjianModel.fromJson(ujian, event.userId)).toList();
        emit(UjianLoaded(ujianList: ujianList));
      } else {
        emit(UjianError(message: 'Failed to load ujian data'));
      }
    } catch (e) {
      emit(UjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchUjian2(FetchUjian2 event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/ujian');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final List<dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        final ujianList = data.map((ujian) => UjianModel.fromJson2(ujian)).toList();
        emit(UjianLoaded(ujianList: ujianList));
      } else {
        emit(UjianError(message: 'Failed to load ujian data'));
      }
    } catch (e) {
      emit(UjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onAddUjian(AddUjian event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/ujian');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'nama' : event.nama,
          'mapel' : event.mapel,
          'tipe_soal' : event.tipe_soal,
          'tipe_ujian' : event.tipe_ujian,
          'durasi' : '${event.durasi.hour}:${event.durasi.minute.toString().padLeft(2, '0')}:00',
          'tanggal' : event.tanggal.toIso8601String().split('T')[0],
          'mulai' : '${event.mulai.hour}:${event.mulai.minute.toString().padLeft(2, '0')}:00',
          'selesai' : '${event.selesai.hour}:${event.selesai.minute.toString().padLeft(2, '0')}:00',
          'deskripsi' : event.deskripsi,
          'id_guru' : event.id_guru
        })
      );

      print('${event.durasi.hour}:${event.durasi.minute.toString().padLeft(2, '0')}:00');
      print("ini add ujian");

      if (response.statusCode == 201) {
        add(FetchUjian2(token: event.token));
      } else {
        print('ini errornya 2');
        emit(UjianError(message: 'Failed to load ujian data'));
      }
    } catch (e) {
      print('ini errornya');
      print(e);
      emit(UjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateUjian(UpdateUjian event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/ujian/${event.id_ujian}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'nama' : event.nama,
            'mapel' : event.mapel,
            'tipe_soal' : event.tipe_soal,
            'tipe_ujian' : event.tipe_ujian,
            'durasi' : '${event.durasi.hour}:${event.durasi.minute.toString().padLeft(2, '0')}:00',
            'tanggal' : event.tanggal.toIso8601String().split('T')[0],
            'mulai' : '${event.mulai.hour}:${event.mulai.minute.toString().padLeft(2, '0')}:00',
            'selesai' : '${event.selesai.hour}:${event.selesai.minute.toString().padLeft(2, '0')}:00',
            'deskripsi' : event.deskripsi,
            'id_guru' : event.id_guru
          })
      );

      print("ini update ujian");

      if (response.statusCode == 200) {
        add(FetchUjian2(token: event.token));
      } else {
        print('ini errornya 2');
        emit(UjianError(message: 'Failed to update ujian data'));
      }
    } catch (e) {
      print('ini errornya');
      print(e);
      emit(UjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteUjian(DeleteUjian event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/ujian/delete/${event.id_ujian}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
      );

      print("ini delete ujian");

      if (response.statusCode == 200) {
        add(FetchUjian2(token: event.token));
      } else {
        print('ini errornya 2');
        emit(UjianError(message: 'Failed to update ujian data'));
      }
    } catch (e) {
      print('ini errornya');
      print(e);
      emit(UjianError(message: 'Error: $e'));
    }
  }
}