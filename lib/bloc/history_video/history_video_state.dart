import 'package:project_ta/models/history_video_model.dart'; // Pastikan model HistoryVideo sudah dibuat

abstract class HistoryVideoState {}

class HistoryVideoInitial extends HistoryVideoState {}

class HistoryVideoLoading extends HistoryVideoState {}

class HistoryVideoLoaded extends HistoryVideoState {
  final List<HistoryVideo> historyVideos;

  HistoryVideoLoaded({required this.historyVideos});
}

class HistoryVideoCreated extends HistoryVideoState {
  final HistoryVideo historyVideo;

  HistoryVideoCreated({required this.historyVideo});
}

class HistoryVideoError extends HistoryVideoState {
  final String message;

  HistoryVideoError({required this.message});
}