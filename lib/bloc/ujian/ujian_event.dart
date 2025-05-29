// bloc/ujian/ujian_event.dart
import 'package:equatable/equatable.dart';

abstract class UjianEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitUjian extends UjianEvent {}

class FetchUjian extends UjianEvent {
  final String token;

  FetchUjian({required this.token});

  @override
  List<Object> get props => [token];
}