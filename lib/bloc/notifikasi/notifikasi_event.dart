import 'package:equatable/equatable.dart';

abstract class NotifikasiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitNotif extends NotifikasiEvent {}

class FetchNotifikasi extends NotifikasiEvent {
  String token;

  FetchNotifikasi({required this.token});

  @override
  List<Object> get props => [token];
}

class MarkAsRead extends NotifikasiEvent {
  int id;
  String token;

  MarkAsRead({required this.id, required this.token});

  @override
  List<Object> get props => [id, token];
}

class MarkAllAsRead extends NotifikasiEvent {
  String token;

  MarkAllAsRead({required this.token});

  @override
  List<Object> get props => [token];
}