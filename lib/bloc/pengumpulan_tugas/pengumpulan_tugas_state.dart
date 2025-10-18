import 'package:equatable/equatable.dart';
import 'package:project_ta/models/pengumpulan_tugas_model.dart';

abstract class PengumpulanTugasState extends Equatable {
  const PengumpulanTugasState();

  @override
  List<Object?> get props => [];
}

class PengumpulanTugasInitial extends PengumpulanTugasState {}

class PengumpulanTugasLoading extends PengumpulanTugasState {}

class PengumpulanTugasLoaded extends PengumpulanTugasState {
  final List<PengumpulanTugasModel> pengumpulan;

  const PengumpulanTugasLoaded(this.pengumpulan);

  @override
  List<Object?> get props => [pengumpulan];
}

class PengumpulanTugasSuccess extends PengumpulanTugasState {
  final dynamic data; // response dari API saat submit
  const PengumpulanTugasSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class PengumpulanTugasError extends PengumpulanTugasState {
  final String message;
  const PengumpulanTugasError(this.message);

  @override
  List<Object?> get props => [message];
}
