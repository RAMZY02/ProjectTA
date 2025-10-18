import 'package:equatable/equatable.dart';
import 'package:project_ta/models/kelas_mengajar_model.dart'; // Pastikan model sesuai

abstract class KelasMengajarState extends Equatable {
  const KelasMengajarState();

  @override
  List<Object?> get props => [];
}

class KelasMengajarInitial extends KelasMengajarState {}

class KelasMengajarLoading extends KelasMengajarState {}

class KelasMengajarLoaded extends KelasMengajarState {
  final List<KelasMengajarModel> kelasMengajarList;

  const KelasMengajarLoaded(this.kelasMengajarList);

  @override
  List<Object?> get props => [kelasMengajarList];
}

class KelasMengajarDetailLoaded extends KelasMengajarState {
  final KelasMengajarModel kelasMengajar;

  const KelasMengajarDetailLoaded(this.kelasMengajar);

  @override
  List<Object?> get props => [kelasMengajar];
}

class KelasMengajarByUserIdLoaded extends KelasMengajarState {
  final List<KelasMengajarModel> kelasMengajarList;

  const KelasMengajarByUserIdLoaded(this.kelasMengajarList);

  @override
  List<Object?> get props => [kelasMengajarList];
}

class KelasMengajarCreated extends KelasMengajarState {
  final KelasMengajarModel kelasMengajar;
  const KelasMengajarCreated(this.kelasMengajar);

  @override
  List<Object?> get props => [kelasMengajar];
}

class KelasMengajarUpdated extends KelasMengajarState {
  final KelasMengajarModel kelasMengajar;
  const KelasMengajarUpdated(this.kelasMengajar);

  @override
  List<Object?> get props => [kelasMengajar];
}

class KelasMengajarDeleted extends KelasMengajarState {
  final int id;
  const KelasMengajarDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class KelasMengajarSuccess extends KelasMengajarState {
  final dynamic data; // response dari API
  const KelasMengajarSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class KelasMengajarError extends KelasMengajarState {
  final String message;
  const KelasMengajarError(this.message);

  @override
  List<Object?> get props => [message];
}