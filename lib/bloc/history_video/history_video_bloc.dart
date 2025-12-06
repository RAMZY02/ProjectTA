import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/models/history_video_model.dart';

import 'history_video_event.dart';
import 'history_video_state.dart'; // Pastikan model HistoryVideo sudah dibuat

class HistoryVideoBloc extends Bloc<HistoryVideoEvent, HistoryVideoState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  HistoryVideoBloc() : super(HistoryVideoInitial()) {
    on<InitialHistoryVideo>(_onInitialHistoryVideo);
    on<FetchHistoryVideo>(_onFetchHistoryVideo);
    on<CreateHistoryVideo>(_onCreateHistoryVideo);
  }

  Future<void> _onInitialHistoryVideo(InitialHistoryVideo event, Emitter<HistoryVideoState> emit) async {
    emit(HistoryVideoInitial());
  }

  Future<void> _onFetchHistoryVideo(FetchHistoryVideo event, Emitter<HistoryVideoState> emit) async {
    emit(HistoryVideoLoading());
    try {
      final url = Uri.parse(
          '$baseUrl/api/history-video/user/${event.userId}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print("ini video history 1");
      print(data);

      if (response.statusCode == 200) {
        final historyVideos = data.map((history) => HistoryVideo.fromJson(history)).toList();
        print(historyVideos);
        emit(HistoryVideoLoaded(historyVideos: historyVideos));
      } else {
        emit(HistoryVideoError(
            message: 'Failed to load history: ${response.statusCode}'));
      }
    } catch (e) {
      print("ini error");
      print(e);
      emit(HistoryVideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onCreateHistoryVideo(
      CreateHistoryVideo event, Emitter<HistoryVideoState> emit) async {
    emit(HistoryVideoLoading());
    try {
      final url = Uri.parse(
          '$baseUrl/api/history-video');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({
          'id_user': event.userId,
          'id_video': event.videoId,
        }),
      );

      print("ini response history video");
      print(response.body);

      if (response.statusCode == 201) {
        final createdHistory = HistoryVideo.fromJson(json.decode(response.body));
        emit(HistoryVideoCreated(historyVideo: createdHistory));
      } else {
        emit(HistoryVideoError(
            message: 'Failed to create history: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HistoryVideoError(message: 'Error: $e'));
    }
  }
}