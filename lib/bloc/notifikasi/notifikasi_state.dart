import 'package:project_ta/models/notifikasi_model.dart';

abstract class NotifikasiState {}

class NotifikasiInitial extends NotifikasiState {}

class NotifikasiLoading extends NotifikasiState {}

class NotifikasiLoaded extends NotifikasiState {
  final List<NotifikasiModel> notif;

  NotifikasiLoaded({required this.notif});
}

class NotifikasiError extends NotifikasiState {
  final String message;

  NotifikasiError({required this.message});
}