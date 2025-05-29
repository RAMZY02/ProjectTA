class HistoryVideo {
  final int id;
  final int idUser;
  final int idVideo;
  final DateTime timestamps;
  final String keyStatus;

  HistoryVideo({
    required this.id,
    required this.idUser,
    required this.idVideo,
    required this.timestamps,
    required this.keyStatus,
  });

  factory HistoryVideo.fromJson(Map<String, dynamic> json) {
    return HistoryVideo(
      id: json['id'] as int,
      idUser: json['id_user'] as int,
      idVideo: json['id_video'] as int,
      timestamps: DateTime.parse(json['timestamps'] as String),
      keyStatus: json['key_status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_video': idVideo,
      'timestamps': timestamps.toIso8601String(),
      'key_status': keyStatus,
    };
  }

  HistoryVideo copyWith({
    int? id,
    int? idUser,
    int? idVideo,
    DateTime? timestamps,
    String? keyStatus,
  }) {
    return HistoryVideo(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      idVideo: idVideo ?? this.idVideo,
      timestamps: timestamps ?? this.timestamps,
      keyStatus: keyStatus ?? this.keyStatus,
    );
  }

  @override
  String toString() {
    return 'HistoryVideo{id: $id, idUser: $idUser, idVideo: $idVideo, timestamps: $timestamps, keyStatus: $keyStatus}';
  }
}