import 'package:equatable/equatable.dart';
import 'package:project_ta/models/video_edukasi_model.dart';

abstract class VideoEdukasiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Init extends VideoEdukasiEvent {}

class FetchVideos extends VideoEdukasiEvent {
  String token;
  int userId;

  FetchVideos({required this.token, required this.userId});

  @override
  List<Object> get props => [token, userId];
}

class LikeVideo extends VideoEdukasiEvent {
  String token;
  int userId;
  int videoId;
  List<VideoEdukasiModel> videos;

  LikeVideo({required this.token, required this.userId, required this.videoId, required this.videos});

  @override
  List<Object> get props => [token, userId, videoId, videos];
}

class UnlikeVideo extends VideoEdukasiEvent {
  String token;
  int userId;
  int videoId;
  List<VideoEdukasiModel> videos;

  UnlikeVideo({required this.token, required this.userId, required this.videoId, required this.videos});

  @override
  List<Object> get props => [token, userId, videoId, videos];
}