import 'package:equatable/equatable.dart';

abstract class WaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitWa extends WaEvent {}

class SendMessage extends WaEvent {
  final String pesan;
  final String tujuan;
  final String token;

  SendMessage({required this.pesan, required this.tujuan, required this.token});
}