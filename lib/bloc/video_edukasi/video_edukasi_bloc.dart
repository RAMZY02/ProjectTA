import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_state.dart';
import 'package:project_ta/models/video_edukasi_model.dart';

class VideoEdukasiBloc extends Bloc<VideoEdukasiEvent, VideoEdukasiState> {

  // final baseUrl = 'http://localhost:3000';
  // final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  VideoEdukasiBloc() : super(VideoInitial()) {
    on<InitVideoEdukasi>(_onInit);
    on<FetchVideos>(_onFetchVideos);
    on<LastId>(_onLastId);
    on<LikeVideo>(_onLikeVideo);
    on<UnlikeVideo>(_onUnlikeVideo);
    on<AddVideo>(_onAddVideo);
    on<UpdateVideo>(_onUpdateVideo);
    on<DeleteVideo>(_onDeleteVideo);
  }

  Future<void> _onInit(InitVideoEdukasi event, Emitter<VideoEdukasiState> emit) async {
    emit(VideoInitial());
  }

  Future<void> _onFetchVideos(FetchVideos event, Emitter<VideoEdukasiState> emit) async {
    emit(VideoLoading());
    final url = Uri.parse('$baseUrl/api/video-edukasi');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final videos = data.map((video) => VideoEdukasiModel.fromJson(video, event.userId)).toList();
        print(videos);
        emit(VideoLoaded(videos: videos));
      } else {
        emit(VideoError(message: 'Failed to load videos'));
      }
    } catch (e) {
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onLastId(LastId event, Emitter<VideoEdukasiState> emit) async{
    final url = Uri.parse('$baseUrl/api/video-edukasi/lastId');
    try{
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        }
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        emit(VideoId(IdVideo: responseBody['idvideo']));
      } else {
        emit(VideoError(message: 'Failed to get last id'));
      }
    }catch(e){
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onLikeVideo(LikeVideo event, Emitter<VideoEdukasiState> emit) async {
    final url = Uri.parse('$baseUrl/api/video-edukasi/${event.videoId}/like');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({'userId': event.userId}),
      );

      final updatedVideo = VideoEdukasiModel.fromJson(json.decode(response.body), event.userId);

      final updatedVideos = event.videos.map((video) {
        return video.id == updatedVideo.id ? updatedVideo : video;
      }).toList();

      if (response.statusCode == 200) {
        emit(VideoLoaded(videos: updatedVideos));
      } else {
        emit(VideoError(message: 'Failed to like video'));
      }
    } catch (e) {
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onUnlikeVideo(UnlikeVideo event, Emitter<VideoEdukasiState> emit) async {
    final url = Uri.parse('$baseUrl/api/video-edukasi/${event.videoId}/unlike');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({'userId': event.userId}),
      );

      final updatedVideo = VideoEdukasiModel.fromJson(json.decode(response.body), event.userId);

      final updatedVideos = event.videos.map((video) {
        return video.id == updatedVideo.id ? updatedVideo : video;
      }).toList();

      if (response.statusCode == 200) {
        emit(VideoLoaded(videos: updatedVideos));
      } else {
        emit(VideoError(message: 'Failed to unlike video'));
      }
    } catch (e) {
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onAddVideo(AddVideo event, Emitter<VideoEdukasiState> emit) async {
    final url = Uri.parse('$baseUrl/api/video-edukasi');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({
          'id_user' : event.idUser,
          'judul': event.videoEdukasi['judul'],
          'link_video': event.videoEdukasi['link_video'],
          'thumbnail': event.videoEdukasi['thumbnail'],
          'deskripsi': event.videoEdukasi['deskripsi'],
          'id_mapel': event.videoEdukasi['id_mapel'],
          'views': event.videoEdukasi['views'],
          'likes': event.videoEdukasi['likes'],
          'kelas': event.videoEdukasi['kelas'],
          'durasi': event.videoEdukasi['durasi']
        }),
      );

      if (response.statusCode == 201) {
        emit(VideoInitial());
      } else {
        emit(VideoError(message: 'Failed to add video'));
      }
    } catch (e) {
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateVideo(UpdateVideo event, Emitter<VideoEdukasiState> emit) async {
    final url = Uri.parse('$baseUrl/api/video-edukasi/${event.idVideo}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({
          'judul': event.videoEdukasi['judul'],
          'link_video': event.videoEdukasi['link_video'],
          'thumbnail': event.videoEdukasi['thumbnail'],
          'deskripsi': event.videoEdukasi['deskripsi'],
          'id_mapel': event.videoEdukasi['id_mapel'],
          'views': event.videoEdukasi['views'],
          'likes': event.videoEdukasi['likes'],
          'kelas': event.videoEdukasi['kelas'],
          'durasi': event.videoEdukasi['durasi']
        }),
      );

      if (response.statusCode == 200) {
        emit(VideoInitial());
      } else {
        emit(VideoError(message: 'Failed to unlike video'));
      }
    } catch (e) {
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteVideo(DeleteVideo event, Emitter<VideoEdukasiState> emit) async {
    final url = Uri.parse('$baseUrl/api/video-edukasi/delete/${event.idVideo}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        add(FetchVideos(token: event.token, userId: event.idUser));
      } else {
        emit(VideoError(message: 'Failed to unlike video'));
      }
    } catch (e) {
      print(e);
      emit(VideoError(message: 'Error: $e'));
    }
  }
}