import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/comments/comments_event.dart';
import 'package:project_ta/bloc/comments/comments_state.dart';
import 'package:project_ta/models/comment_model.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';

  CommentsBloc() : super(CommentsInitial()) {
    on<FetchComments>(_onFetchComments);
    on<FetchAllComments>(_onFetchAllComments);
    on<AddComment>(_onAddComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<InitComment>(_onInit);
    on<LikeComment>(_onLikeComment);
    on<UnlikeComment>(_onUnlikeComment);
  }

  Future<void> _onFetchComments(FetchComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    try {
      final url = Uri.parse('$baseUrl/api/comments/video/${event.videoId}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final comments = data.map((comment) => CommentModel.fromJson(comment, event.id_user)).toList();
        emit(CommentsLoaded(comments: comments));
      } else {
        print("masuk sini not found");
        emit(CommentsNotFound(message: 'komentar belum ada'));
      }
    } catch (e) {
      emit(CommentsError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchAllComments(FetchAllComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    try {
      final url = Uri.parse('$baseUrl/api/comments');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final comments = data.map((comment) => CommentModel.fromJson2(comment)).toList();
        emit(CommentsLoaded(comments: comments));
      } else {
        print("masuk sini not found");
        emit(CommentsNotFound(message: 'komentar belum ada'));
      }
    } catch (e) {
      emit(CommentsError(message: 'Error: $e'));
    }
  }

  Future<void> _onAddComment(
      AddComment event, Emitter<CommentsState> emit) async {
    try {
      final url = Uri.parse('$baseUrl/api/comments/admin');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({
          'id_video': event.videoId,
          'id_user': event.id_user,
          'komentar': event.komentar,
        }),
      );

      if (response.statusCode == 201) {
        // Jika komentar berhasil ditambahkan, muat ulang komentar
        add(FetchComments(token: event.token, id_user: event.id_user, videoId: event.videoId));
      } else {
        emit(CommentsError(message: 'Gagal menambahkan komentar'));
      }
    } catch (e) {
      emit(CommentsError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateComment(
      UpdateComment event, Emitter<CommentsState> emit) async {
    try {
      final url = Uri.parse('$baseUrl/api/comments/${event.id_comment}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({
          'id_video': event.videoId,
          'id_user': event.id_user,
          'komentar': event.komentar,
        }),
      );

      if (response.statusCode == 201) {
        // Jika komentar berhasil ditambahkan, muat ulang komentar
        add(FetchAllComments(token: event.token));
      } else {
        emit(CommentsError(message: 'Gagal menambahkan komentar'));
      }
    } catch (e) {
      emit(CommentsError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteComment(
      DeleteComment event, Emitter<CommentsState> emit) async {
    try {
      final url = Uri.parse('$baseUrl/api/comments/delete/${event.id_comment}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        }
      );

      print("ini body");
      print(response.body);

      if (response.statusCode == 200) {
        // Jika komentar berhasil ditambahkan, muat ulang komentar
        add(FetchAllComments(token: event.token));
      } else {
        emit(CommentsError(message: 'Gagal menambahkan komentar'));
      }
    } catch (e) {
      print("ini error");
      print(e);
      emit(CommentsError(message: 'Error: $e'));
    }
  }

  Future<void> _onInit(InitComment event, Emitter<CommentsState> emit) async {
    emit(CommentsInitial());
  }

  Future<void> _onLikeComment(
      LikeComment event,
      Emitter<CommentsState> emit,
      ) async {
    try {

      final response = await http.post(
        Uri.parse('$baseUrl/api/comments/${event.commentId}/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({'userId': event.userId, 'videoId' : event.videoId}),
      );

      print(response.body);

      final updatedComment = CommentModel.fromJson(json.decode(response.body), event.userId);

      final updatedComments = event.comments.map((comment) {
        return comment.id == updatedComment.id ? updatedComment : comment;
      }).toList();

      emit(CommentsLoaded(comments: updatedComments));
    } catch (e) {
      emit(CommentsError(message: 'Error: $e'));
    }
  }

  Future<void> _onUnlikeComment(
      UnlikeComment event,
      Emitter<CommentsState> emit,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/comments/${event.commentId}/unlike'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: json.encode({'userId': event.id_user}),
      );

      final updatedComment = CommentModel.fromJson(json.decode(response.body), event.id_user);

      final updatedComments = event.comments.map((comment) {
        return comment.id == updatedComment.id ? updatedComment : comment;
      }).toList();

      emit(CommentsLoaded(comments: updatedComments));
    } catch (e) {
      emit(CommentsError(message: 'Error: $e'));
    }
  }
}