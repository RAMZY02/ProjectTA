import 'package:equatable/equatable.dart';

abstract class NotifikasiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Init extends NotifikasiEvent {}

class FetchNotifikasi extends NotifikasiEvent {
  String token;

  FetchNotifikasi({required this.token});

  @override
  List<Object> get props => [token];
}