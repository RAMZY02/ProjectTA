import 'package:equatable/equatable.dart';
import 'package:project_ta/models/comment_model.dart';

abstract class CommentsState extends Equatable {
  @override
  List<Object> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;

  CommentsLoaded({required this.comments});

  @override
  List<Object> get props => [comments];
}

class CommentAdded extends CommentsState {
  final List<CommentModel> comments;

  CommentAdded({required this.comments});

  @override
  List<Object> get props => [comments];
}

class CommentsError extends CommentsState {
  final String message;

  CommentsError({required this.message});

  @override
  List<Object> get props => [message];
}

class CommentsNotFound extends CommentsState {
  final String message;

  CommentsNotFound({required this.message});

  @override
  List<Object> get props => [message];
}