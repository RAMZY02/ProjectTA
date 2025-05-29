// bloc/ujian/ujian_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';

class UjianBloc extends Bloc<UjianEvent, UjianState> {
  UjianBloc() : super(UjianInitial()) {
    on<InitUjian>(_onInit);
    on<FetchUjian>(_onFetchUjian);
  }

  Future<void> _onFetchUjian(FetchUjian event, Emitter<UjianState> emit) async {
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
        final ujianList = data.map((ujian) => UjianModel.fromJson(ujian)).toList();
        emit(UjianLoaded(ujianList: ujianList));
      } else {
        emit(UjianError(message: 'Failed to load ujian data'));
      }
    } catch (e) {
      emit(UjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onInit(InitUjian event, Emitter<UjianState> emit) async {
    emit(UjianInitial());
  }
}