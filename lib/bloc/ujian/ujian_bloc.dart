// bloc/ujian/ujian_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';

class UjianBloc extends Bloc<UjianEvent, UjianState> {

  final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  UjianBloc() : super(UjianInitial()) {
    on<InitUjian>(_onInitUjian);
    on<FetchUjian>(_onFetchUjian);
    on<FetchUjian2>(_onFetchUjian2);
    on<FetchAllUjianByIdMapel>(_onFetchAllUjianByIdMapel);
    on<FetchAllUjianByIdGuru>(_onFetchAllUjianByIdGuru);
    on<FetchKoreksiUjianByIdGuru>(_onFetchKoreksiUjianByIdGuru);
    on<FetchUjianByIdMapel>(_onFetchUjianByIdMapel);
    on<AddUjian>(_onAddUjian);
    on<UpdateUjian>(_onUpdateUjian);
    on<DeleteUjian>(_onDeleteUjian);
    on<CekUjianBerlangsung>(_onCekUjianBerlangsung);
  }

  Future<void> _onInitUjian(InitUjian event, Emitter<UjianState> emit) async {
    emit(UjianInitial());
  }

  Future<void> _onFetchUjian(FetchUjian event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('$baseUrl/api/ujian/belum-selesai/${event.kelas}/${event.userId}');

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
    final url = Uri.parse('$baseUrl/api/ujian');

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

  Future<void> _onFetchAllUjianByIdMapel(FetchAllUjianByIdMapel event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('$baseUrl/api/ujian/mapel/${event.id_mapel}');

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

  Future<void> _onFetchAllUjianByIdGuru(FetchAllUjianByIdGuru event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('$baseUrl/api/ujian/guru/${event.id_guru}');

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
      }
      else if(response.statusCode == 404){
        emit(UjianLoaded(ujianList: []));
      }
      else {
        emit(UjianError(message: 'Failed to load ujian data'));
      }
    } catch (e) {
      emit(UjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchKoreksiUjianByIdGuru(FetchKoreksiUjianByIdGuru event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('$baseUrl/api/ujian/koreksi/guru/${event.id_guru}');

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

  Future<void> _onFetchUjianByIdMapel(FetchUjianByIdMapel event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('$baseUrl/api/ujian/UH/${event.id_mapel}');

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
    final url = Uri.parse('$baseUrl/api/ujian');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'nama' : event.nama,
          'id_mapel' : event.id_mapel,
          'tingkatan' : event.tingkatan,
          'kelas' : event.kelas,
          'tipe_soal' : event.tipe_soal,
          'tipe_ujian' : event.tipe_ujian,
          'tanggal' : event.tanggal.toIso8601String().split('T')[0],
          'mulai' : '${event.mulai.hour}:${event.mulai.minute.toString().padLeft(2, '0')}:00',
          'selesai' : '${event.selesai.hour}:${event.selesai.minute.toString().padLeft(2, '0')}:00',
          'deskripsi' : event.deskripsi,
          'kode' : event.kode,
          'id_guru' : event.id_guru
        })
      );

      print("ini add ujian");

      if (response.statusCode == 201) {
        emit(UjianInitial());
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
    final url = Uri.parse('$baseUrl/api/ujian/${event.id_ujian}');
    try {
      final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'nama' : event.nama,
            'id_mapel' : event.id_mapel,
            'tingkatan' : event.tingkatan,
            'kelas' : event.kelas,
            'tipe_soal' : event.tipe_soal,
            'tipe_ujian' : event.tipe_ujian,
            'tanggal' : event.tanggal.toIso8601String().split('T')[0],
            'mulai' : '${event.mulai.hour}:${event.mulai.minute.toString().padLeft(2, '0')}:00',
            'selesai' : '${event.selesai.hour}:${event.selesai.minute.toString().padLeft(2, '0')}:00',
            'deskripsi' : event.deskripsi,
            'id_guru' : event.id_guru
          })
      );

      print("ini update ujian");

      if (response.statusCode == 200) {
        emit(UjianInitial());
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
    final url = Uri.parse('$baseUrl/api/ujian/delete/${event.id_ujian}');
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
        emit(UjianInitial());
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

  Future<void> _onCekUjianBerlangsung(CekUjianBerlangsung event, Emitter<UjianState> emit) async {
    emit(UjianLoading());
    final url = Uri.parse('$baseUrl/api/ujian/sedang-berlangsung/${event.id_user}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final ujian = UjianModel.fromJson2(data);
        emit(UjianBerlangsung(ujian: ujian));
      }
      else if(response.statusCode == 404){
        emit(UjianInitial());
      }
      else {
        emit(UjianError(message: 'Failed to load ujian berlangsung'));
      }
    } catch (e) {
      emit(UjianError(message: 'Error: $e'));
    }
  }
}