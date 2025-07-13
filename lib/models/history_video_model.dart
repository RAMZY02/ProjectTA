import 'package:project_ta/models/video_edukasi_model.dart';

class HistoryVideo {
  final int id;
  final int idUser;
  final int idVideo;
  final DateTime timestamps;
  final String keyStatus;
  final VideoEdukasiModel video;

  HistoryVideo({
    required this.id,
    required this.idUser,
    required this.idVideo,
    required this.timestamps,
    required this.keyStatus,
    required this.video,
  });

  factory HistoryVideo.fromJson(Map<String, dynamic> json) {
    return HistoryVideo(
      id: json['id'],
      idUser: json['id_user'],
      idVideo: json['id_video'],
      timestamps: DateTime.parse(json['timestamps']),
      keyStatus: json['key_status'],
      video: VideoEdukasiModel.fromJson(json['video'], json['id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_video': idVideo,
      'timestamps': timestamps.toIso8601String(),
      'key_status': keyStatus,
      'video': video,
    };
  }

  HistoryVideo copyWith({
    int? id,
    int? idUser,
    int? idVideo,
    DateTime? timestamps,
    String? keyStatus,
    VideoEdukasiModel? video,
  }) {
    return HistoryVideo(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      idVideo: idVideo ?? this.idVideo,
      timestamps: timestamps ?? this.timestamps,
      keyStatus: keyStatus ?? this.keyStatus,
      video: video ?? this.video,
    );
  }

  @override
  String toString() {
    return 'HistoryVideo{id: $id, idUser: $idUser, idVideo: $idVideo, timestamps: $timestamps, keyStatus: $keyStatus, video: $video}';
  }
}