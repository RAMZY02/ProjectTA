class VideoEdukasiModel {
  final int id;
  final int id_user;
  final String judul;
  final String mata_pelajaran;
  final String link_video;
  final String kelas; // Changed to String since it's CHAR(1) in DB
  final int views;
  final int likes;
  final List<dynamic> liked;
  final bool isLikedByMe;
  final String deskripsi;

  VideoEdukasiModel({
    required this.id,
    required this.id_user,
    required this.judul,
    required this.mata_pelajaran,
    required this.link_video,
    required this.kelas,
    required this.views,
    required this.likes,
    required this.liked,
    required this.deskripsi,
    this.isLikedByMe = false,
  });

  factory VideoEdukasiModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    return VideoEdukasiModel(
      id: json['id'],
      id_user: json['id_user'],
      judul: json['judul'],
      mata_pelajaran: json['mata_pelajaran'],
      link_video: json['link_video'],
      deskripsi: json['deskripsi'],
      kelas: json['kelas'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? [],
      isLikedByMe: (json['liked'] as List<dynamic>).contains(currentUserId)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': id_user,
      'judul': judul,
      'mata_pelajaran': mata_pelajaran,
      'link_video': link_video,
      'kelas': kelas,
      'views': views,
      'likes': likes,
      'liked': liked,
      'isLikedByMe' : isLikedByMe,
      'deskripsi' : deskripsi
    };
  }
}