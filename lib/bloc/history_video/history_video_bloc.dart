import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/models/history_video_model.dart';

import 'history_video_event.dart';
import 'history_video_state.dart'; // Pastikan model HistoryVideo sudah dibuat

class HistoryVideoBloc extends Bloc<HistoryVideoEvent, HistoryVideoState> {
  HistoryVideoBloc() : super(HistoryVideoInitial()) {
    on<FetchHistoryVideo>(_onFetchHistoryVideo);
    on<CreateHistoryVideo>(_onCreateHistoryVideo);
  }

  Future<void> _onFetchHistoryVideo(
      FetchHistoryVideo event, Emitter<HistoryVideoState> emit) async {
    emit(HistoryVideoLoading());
    try {
      final url = Uri.parse(
          'https://flounder-moved-roster.ngrok-free.app/api/history-video');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final historyVideos = data
            .map((history) => HistoryVideo.fromJson(history))
            .toList();
        emit(HistoryVideoLoaded(historyVideos: historyVideos));
      } else {
        emit(HistoryVideoError(
            message: 'Failed to load history: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HistoryVideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onCreateHistoryVideo(
      CreateHistoryVideo event, Emitter<HistoryVideoState> emit) async {
    emit(HistoryVideoLoading());
    try {
      final url = Uri.parse(
          'https://flounder-moved-rooster.ngrok-free.app/api/history-video');
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