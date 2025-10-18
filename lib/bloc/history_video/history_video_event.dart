import 'package:equatable/equatable.dart';

abstract class HistoryVideoEvent extends Equatable {
  const HistoryVideoEvent();

  @override
  List<Object> get props => [];
}

class InitialHistoryVideo extends HistoryVideoEvent{}

class FetchHistoryVideo extends HistoryVideoEvent {
  final String token;
  final int userId;

  const FetchHistoryVideo({
    required this.token,
    required this.userId,
  });

  @override
  List<Object> get props => [token, userId];
}

class CreateHistoryVideo extends HistoryVideoEvent {
  final String token;
  final int userId;
  final int videoId;

  const CreateHistoryVideo({
    required this.token,
    required this.userId,
    required this.videoId,
  });

  @override
  List<Object> get props => [token, userId, videoId];
}

class ResetHistoryVideo extends HistoryVideoEvent {
  const ResetHistoryVideo();
}

class UpdateHistoryVideoStatus extends HistoryVideoEvent {
  final String token;
  final int historyId;
  final String status;

  const UpdateHistoryVideoStatus({
    required this.token,
    required this.historyId,
    required this.status,
  });

  @override
  List<Object> get props => [token, historyId, status];
}

class DeleteHistoryVideo extends HistoryVideoEvent {
  final String token;
  final int historyId;

  const DeleteHistoryVideo({
    required this.token,
    required this.historyId,
  });

  @override
  List<Object> get props => [token, historyId];
}