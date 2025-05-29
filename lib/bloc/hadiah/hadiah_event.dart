import 'package:equatable/equatable.dart';
import 'package:project_ta/models/hadiah_model.dart';

abstract class HadiahEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Inits extends HadiahEvent {}

class FetchHadiah extends HadiahEvent {
  String token;

  FetchHadiah({required this.token});
}

class TukarHadiah extends HadiahEvent{
  String token;
  int userId;
  int hadiahId;
  List<HadiahModel> hadiah;

  TukarHadiah({required this.token, required this.userId, required this.hadiahId, required this.hadiah});
}