import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_event.dart';
import 'package:project_ta/models/notifikasi_model.dart';
import 'notifikasi_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotifikasiBloc extends Bloc<NotifikasiEvent, NotifikasiState> {
  NotifikasiBloc() : super(NotifikasiInitial()) {
    on<Init>(_onInit);
    on<FetchNotifikasi>(_onFetchNotifikasi);
  }

  Future<void> _onFetchNotifikasi(FetchNotifikasi event, Emitter<NotifikasiState> emit) async {
    emit(NotifikasiLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/notifikasi');

    try {
      print("masuk 2");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print(response.body);
      print("masuk 3");
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        print("masuk 4");
        final notifikasi = data.map((notif) => NotifikasiModel.fromJson(notif)).toList();
        print(notifikasi);
        emit(NotifikasiLoaded(notif: notifikasi));
      } else {
        emit(NotifikasiError(message: 'Failed to load videos'));
      }
    } catch (e) {
      print(e);
      emit(NotifikasiError(message: 'Error: $e'));
    }
  }

  Future<void> _onInit(Init event, Emitter<NotifikasiState> emit) async {
    emit(NotifikasiInitial());
  }
}