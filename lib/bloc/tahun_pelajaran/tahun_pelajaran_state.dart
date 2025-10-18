import 'package:equatable/equatable.dart';
import 'package:project_ta/models/tahun_pelajaran_model.dart'; // Ganti dengan model yang sesuai

abstract class TahunPelajaranState extends Equatable {
  const TahunPelajaranState();

  @override
  List<Object?> get props => [];
}

class TahunPelajaranInitial extends TahunPelajaranState {}

class TahunPelajaranLoading extends TahunPelajaranState {}

class TahunPelajaranLoaded extends TahunPelajaranState {
  final List<TahunPelajaranModel> tahunPelajaranList;

  const TahunPelajaranLoaded(this.tahunPelajaranList);

  @override
  List<Object?> get props => [tahunPelajaranList];
}

class TahunPelajaranDetailLoaded extends TahunPelajaranState {
  final TahunPelajaranModel tahunPelajaran;

  const TahunPelajaranDetailLoaded(this.tahunPelajaran);

  @override
  List<Object?> get props => [tahunPelajaran];
}

class TahunPelajaranCreated extends TahunPelajaranState {
  final TahunPelajaranModel tahunPelajaran;
  const TahunPelajaranCreated(this.tahunPelajaran);

  @override
  List<Object?> get props => [tahunPelajaran];
}

class TahunPelajaranUpdated extends TahunPelajaranState {
  final TahunPelajaranModel tahunPelajaran;
  const TahunPelajaranUpdated(this.tahunPelajaran);

  @override
  List<Object?> get props => [tahunPelajaran];
}

class TahunPelajaranDeleted extends TahunPelajaranState {
  final int id;
  const TahunPelajaranDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TahunPelajaranSuccess extends TahunPelajaranState {
  final String message;
  final dynamic data; // response dari API
  const TahunPelajaranSuccess({this.message = '', this.data});

  @override
  List<Object?> get props => [message, data];
}

class TahunPelajaranError extends TahunPelajaranState {
  final String message;
  const TahunPelajaranError(this.message);

  @override
  List<Object?> get props => [message];
}