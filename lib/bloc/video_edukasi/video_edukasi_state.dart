import '../../models/video_edukasi_model.dart';

abstract class VideoEdukasiState {}

class VideoInitial extends VideoEdukasiState {}

class VideoLoading extends VideoEdukasiState {}

class VideoLoaded extends VideoEdukasiState {
  final List<VideoEdukasiModel> videos;

  VideoLoaded({required this.videos});
}

class VideoError extends VideoEdukasiState {
  final String message;

  VideoError({required this.message});
}
