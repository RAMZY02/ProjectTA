import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/WA/WA_event.dart';
import 'package:project_ta/bloc/WA/WA_state.dart';
import 'package:http/http.dart' as http;

import '../../models/WA_model.dart';

class WaBloc extends Bloc<WaEvent, WaState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  WaBloc() : super(WaInitial()) {
    on<InitWa>(_onInit);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onInit(InitWa event, Emitter<WaState> emit) async {
    emit(WaInitial());
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<WaState> emit) async {
    final url = Uri.parse('$baseUrl/api/WA');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({'tujuan' : event.tujuan, 'pesan' : event.pesan}),
      );

      final responseBody = json.decode(response.body);
      final pesanTerkirim = WaModel.fromJson(responseBody);

      if (response.statusCode == 200) {
        emit(WaLoaded(success: responseBody["success"], message: responseBody["message"], data: pesanTerkirim));
      } else {
        emit(WaError(message: 'Failed to send message'));
      }
    } catch (e) {
      print(e);
      emit(WaError(message: 'Error: $e'));
    }
  }
}