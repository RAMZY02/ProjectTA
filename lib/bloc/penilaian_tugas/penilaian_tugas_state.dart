import 'package:equatable/equatable.dart';
import 'package:project_ta/models/penilaian_tugas_model.dart'; // Pastikan model sesuai

abstract class PenilaianTugasState extends Equatable {
  const PenilaianTugasState();

  @override
  List<Object?> get props => [];
}

class PenilaianTugasInitial extends PenilaianTugasState {}

class PenilaianTugasLoading extends PenilaianTugasState {}

class PenilaianTugasLoaded extends PenilaianTugasState {
  final List<PenilaianTugasModel> penilaianList;

  const PenilaianTugasLoaded(this.penilaianList);

  @override
  List<Object?> get props => [penilaianList];
}

class PenilaianTugasDetailLoaded extends PenilaianTugasState {
  final PenilaianTugasModel penilaian;

  const PenilaianTugasDetailLoaded(this.penilaian);

  @override
  List<Object?> get props => [penilaian];
}

class PenilaianTugasCreated extends PenilaianTugasState {
  final PenilaianTugasModel penilaian;
  const PenilaianTugasCreated(this.penilaian);

  @override
  List<Object?> get props => [penilaian];
}

class PenilaianTugasUpdated extends PenilaianTugasState {
  final PenilaianTugasModel penilaian;
  const PenilaianTugasUpdated(this.penilaian);

  @override
  List<Object?> get props => [penilaian];
}

class PenilaianTugasDeleted extends PenilaianTugasState {
  final int id;
  const PenilaianTugasDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class PenilaianTugasSuccess extends PenilaianTugasState {
  final dynamic data; // response dari API
  const PenilaianTugasSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class PenilaianTugasError extends PenilaianTugasState {
  final String message;
  const PenilaianTugasError(this.message);

  @override
  List<Object?> get props => [message];
}