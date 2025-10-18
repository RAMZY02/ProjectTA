import 'package:equatable/equatable.dart';
import 'package:project_ta/models/mata_pelajaran_model.dart'; // Pastikan model sesuai

abstract class MataPelajaranState extends Equatable {
  const MataPelajaranState();

  @override
  List<Object?> get props => [];
}

class MataPelajaranInitial extends MataPelajaranState {}

class MataPelajaranLoading extends MataPelajaranState {}

class MataPelajaranLoaded extends MataPelajaranState {
  final List<MataPelajaranModel> mataPelajaranList;

  const MataPelajaranLoaded(this.mataPelajaranList);

  @override
  List<Object?> get props => [mataPelajaranList];
}

class MataPelajaranDetailLoaded extends MataPelajaranState {
  final MataPelajaranModel mataPelajaran;

  const MataPelajaranDetailLoaded(this.mataPelajaran);

  @override
  List<Object?> get props => [mataPelajaran];
}

class MataPelajaranCreated extends MataPelajaranState {
  final MataPelajaranModel mataPelajaran;
  const MataPelajaranCreated(this.mataPelajaran);

  @override
  List<Object?> get props => [mataPelajaran];
}

class MataPelajaranUpdated extends MataPelajaranState {
  final MataPelajaranModel mataPelajaran;
  const MataPelajaranUpdated(this.mataPelajaran);

  @override
  List<Object?> get props => [mataPelajaran];
}

class MataPelajaranDeleted extends MataPelajaranState {
  final int id;
  const MataPelajaranDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class MataPelajaranRestored extends MataPelajaranState {
  final int id;
  const MataPelajaranRestored(this.id);

  @override
  List<Object?> get props => [id];
}

class MataPelajaranSuccess extends MataPelajaranState {
  final dynamic data; // response dari API
  const MataPelajaranSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class MataPelajaranError extends MataPelajaranState {
  final String message;
  const MataPelajaranError(this.message);

  @override
  List<Object?> get props => [message];
}