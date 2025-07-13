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

class AddVideo extends VideoEdukasiEvent {
  String token;
  int idUser;
  Map<String, Object> videoEdukasi;

  AddVideo({required this.token, required this.idUser, required this.videoEdukasi});

  @override
  List<Object> get props => [token, idUser, videoEdukasi];
}

class UpdateVideo extends VideoEdukasiEvent {
  String token;
  int idUser;
  int idVideo;
  Map<String, Object> videoEdukasi;

  UpdateVideo({required this.token, required this.idVideo, required this.idUser, required this.videoEdukasi});

  @override
  List<Object> get props => [token, idVideo, idUser, videoEdukasi];
}

class DeleteVideo extends VideoEdukasiEvent {
  String token;
  int idUser;
  int idVideo;

  DeleteVideo({required this.token, required this.idVideo, required this.idUser});

  @override
  List<Object> get props => [token, idVideo, idUser];
}