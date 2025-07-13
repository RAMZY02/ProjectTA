import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_event.dart';
import 'package:project_ta/models/notifikasi_model.dart';
import 'notifikasi_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotifikasiBloc extends Bloc<NotifikasiEvent, NotifikasiState> {
  NotifikasiBloc() : super(NotifikasiInitial()) {
    on<InitNotif>(_onInit);
    on<FetchNotifikasi>(_onFetchNotifikasi);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onInit(InitNotif event, Emitter<NotifikasiState> emit) async {
    emit(NotifikasiInitial());
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

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<NotifikasiState> emit) async {
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/notifikasi/markasread/${event.id}');
    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final List<dynamic> data = json.decode(response.body);
      print("ini data notif");
      print(data);

      if (response.statusCode == 200) {
        emit(NotifikasiInitial());
      } else {
        emit(NotifikasiError(message: 'Failed to read notif'));
      }
    } catch (e) {
      print(e);
      emit(NotifikasiError(message: 'Error: $e'));
    }
  }

  Future<void> _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotifikasiState> emit) async {
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/notifikasi/markallasread');
    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final List<dynamic> data = json.decode(response.body);
      print("ini data notif");
      print(data);

      if (response.statusCode == 200) {
        emit(NotifikasiInitial());
      } else {
        emit(NotifikasiError(message: 'Failed to read notif'));
      }
    } catch (e) {
      print(e);
      emit(NotifikasiError(message: 'Error: $e'));
    }
  }
}