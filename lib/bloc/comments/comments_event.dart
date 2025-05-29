import 'package:equatable/equatable.dart';

import '../../models/comment_model.dart';

abstract class CommentsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchComments extends CommentsEvent {
  final int videoId;
  final String token;
  final int id_user;

  FetchComments({required this.videoId, required this.token, required this.id_user});

  @override
  List<Object> get props => [videoId, token, id_user];
}

class AddComment extends CommentsEvent {
  final int videoId;
  final String komentar;
  final String token;
  final int id_user;

  AddComment({
    required this.videoId,
    required this.komentar,
    required this.token,
    required this.id_user,
  });

  @override
  List<Object> get props => [videoId, komentar, token, id_user];
}

class InitComment extends CommentsEvent{
  InitComment();

  @override
  List<Object> get props => [];
}

class LikeComment extends CommentsEvent {
  final int commentId;
  final int videoId;
  final int userId;
  final String token;
  final List<CommentModel> comments;

  LikeComment(this.commentId, this.videoId, this.userId, this.token, this.comments);

  @override
  List<Object> get props => [commentId, videoId, userId, token, comments];
}

class UnlikeComment extends CommentsEvent {
  final int commentId;
  final int userId;
  final String token;
  final List<CommentModel> comments;
  final int id_user;

  UnlikeComment(this.commentId, this.userId, this.token, this.comments, this.id_user);

  @override
  List<Object> get props => [commentId, userId, token, comments, id_user];
}