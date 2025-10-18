import 'package:equatable/equatable.dart';
import 'package:project_ta/models/video_edukasi_model.dart';

abstract class VideoEdukasiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitVideoEdukasi extends VideoEdukasiEvent {}

class FetchVideos extends VideoEdukasiEvent {
  final String token;
  final int userId;

  FetchVideos({required this.token, required this.userId});

  @override
  List<Object> get props => [token, userId];
}

class LastId extends VideoEdukasiEvent {
  final String token;

  LastId({required this.token});

  @override
  List<Object> get props => [token];
}

class LikeVideo extends VideoEdukasiEvent {
  final String token;
  final int userId;
  final int videoId;
  final List<VideoEdukasiModel> videos;

  LikeVideo({required this.token, required this.userId, required this.videoId, required this.videos});

  @override
  List<Object> get props => [token, userId, videoId, videos];
}

class UnlikeVideo extends VideoEdukasiEvent {
  final String token;
  final int userId;
  final int videoId;
  final List<VideoEdukasiModel> videos;

  UnlikeVideo({required this.token, required this.userId, required this.videoId, required this.videos});

  @override
  List<Object> get props => [token, userId, videoId, videos];
}

class AddVideo extends VideoEdukasiEvent {
  final String token;
  final int idUser;
  final Map<String, Object> videoEdukasi;

  AddVideo({required this.token, required this.idUser, required this.videoEdukasi});

  @override
  List<Object> get props => [token, idUser, videoEdukasi];
}

class UpdateVideo extends VideoEdukasiEvent {
  final String token;
  final int idUser;
  final int idVideo;
  final Map<String, Object> videoEdukasi;

  UpdateVideo({required this.token, required this.idVideo, required this.idUser, required this.videoEdukasi});

  @override
  List<Object> get props => [token, idVideo, idUser, videoEdukasi];
}

class DeleteVideo extends VideoEdukasiEvent {
  final String token;
  final int idUser;
  final int idVideo;

  DeleteVideo({required this.token, required this.idVideo, required this.idUser});

  @override
  List<Object> get props => [token, idVideo, idUser];
}