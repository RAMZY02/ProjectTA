class VideoEdukasiModel {
  final int id;
  final int id_user;
  final int id_mapel;
  final String judul;
  final String mapel;
  final String link_video;
  final String thumbnail;
  final String kelas; // Changed to String since it's CHAR(1) in DB
  final int views;
  final int likes;
  final List<dynamic> liked;
  final bool isLikedByMe;
  final String deskripsi;
  final String nama_user;

  VideoEdukasiModel({
    required this.id,
    required this.id_user,
    required this.id_mapel,
    required this.judul,
    required this.mapel,
    required this.link_video,
    required this.thumbnail,
    required this.kelas,
    required this.views,
    required this.likes,
    required this.liked,
    required this.deskripsi,
    this.isLikedByMe = false,
    required this.nama_user,
  });

  factory VideoEdukasiModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    return VideoEdukasiModel(
      id: json['id'],
      id_user: json['id_user'],
      id_mapel: json['id_mapel'],
      judul: json['judul'],
      mapel: json['mapel'],
      link_video: json['link_video'],
      thumbnail: json['thumbnail'],
      deskripsi: json['deskripsi'],
      kelas: json['kelas'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? [],
      isLikedByMe: (json['liked'] as List<dynamic>).contains(currentUserId),
      nama_user: json['nama_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': id_user,
      'judul': judul,
      'mapel': mapel,
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