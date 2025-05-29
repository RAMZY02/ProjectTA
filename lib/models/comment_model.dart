import 'package:equatable/equatable.dart';
import 'package:project_ta/models/user_model.dart';

class CommentModel extends Equatable {
  final int id;
  final int idVideo;
  final String komentar;
  final int likes;
  final List<dynamic> liked;
  final UserModel user;
  final DateTime waktu;
  final bool isLikedByMe;

  const CommentModel({
    required this.id,
    required this.idVideo,
    required this.komentar,
    required this.likes,
    required this.liked,
    required this.user,
    required this.waktu,
    this.isLikedByMe = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    return CommentModel(
      id: json['id'],
      idVideo: json['id_video'],
      komentar: json['komentar'],
      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? [],
      user: UserModel.fromJson(json['user']),
      waktu: DateTime.parse(json['waktu']),
      isLikedByMe: (json['liked'] as List<dynamic>).contains(currentUserId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_video': idVideo,
      'komentar': komentar,
      'likes': likes,
      'liked': liked,
      'user': user.toJson(),
      'waktu': waktu,
      'isLikedByMe' : isLikedByMe
    };
  }

  CommentModel copyWith({
    int? id,
    int? idVideo,
    String? komentar,
    int? likes,
    List<dynamic>? liked,
    UserModel? user,
    DateTime? waktu,
    bool? isLikedByMe,
  }) {
    return CommentModel(
      id: id ?? this.id,
      idVideo: idVideo ?? this.idVideo,
      komentar: komentar ?? this.komentar,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
      user: user ?? this.user,
      waktu: waktu ?? this.waktu,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  @override
  List<Object> get props => [id, idVideo, komentar, likes, liked, user, waktu,isLikedByMe];
}