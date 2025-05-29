class VideoEdukasiModel {
  final int id;
  final String judul;
  final String mata_pelajaran;
  final String link_video;
  final String kelas; // Changed to String since it's CHAR(1) in DB
  final int views;
  final int likes;
  final Duration durasi; // Using Duration to represent TIME
  final List<dynamic> liked;
  final bool isLikedByMe;

  VideoEdukasiModel({
    required this.id,
    required this.judul,
    required this.mata_pelajaran,
    required this.link_video,
    required this.kelas,
    required this.views,
    required this.likes,
    required this.durasi,
    required this.liked,
    this.isLikedByMe = false,
  });

  factory VideoEdukasiModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    return VideoEdukasiModel(
      id: json['id'],
      judul: json['judul'],
      mata_pelajaran: json['mata_pelajaran'],
      link_video: json['link_video'],
      kelas: json['kelas'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      durasi: _parseDuration(json['durasi']),
      liked: json['liked'] ?? [],
      isLikedByMe: (json['liked'] as List<dynamic>).contains(currentUserId)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'mata_pelajaran': mata_pelajaran,
      'link_video': link_video,
      'kelas': kelas,
      'views': views,
      'likes': likes,
      'durasi': _formatDuration(durasi),
      'liked': liked,
      'isLikedByMe' : isLikedByMe
    };
  }

  // Helper function to parse TIME string (HH:MM:SS) to Duration
  static Duration _parseDuration(String timeString) {
    final parts = timeString.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
  }

  // Helper function to format Duration to TIME string (HH:MM:SS)
  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}