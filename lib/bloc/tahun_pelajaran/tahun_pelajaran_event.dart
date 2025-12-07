import 'package:equatable/equatable.dart';

abstract class TahunPelajaranEvent extends Equatable {
  const TahunPelajaranEvent();

  @override
  List<Object?> get props => [];
}

class InitTahunPelajaran extends TahunPelajaranEvent{
  InitTahunPelajaran();

  @override
  List<Object> get props => [];
}

class FetchAllTahunPelajaran extends TahunPelajaranEvent {
  final String token;

  const FetchAllTahunPelajaran({
    required this.token
  });

  @override
  List<Object?> get props => [];
}

class FetchTahunPelajaranById extends TahunPelajaranEvent {
  final String token;
  final int id;

  const FetchTahunPelajaranById({required this.id, required this.token});

  @override
  List<Object?> get props => [id];
}

class CreateTahunPelajaran extends TahunPelajaranEvent {
  final String token;
  final String tahun;
  final String semester;

  const CreateTahunPelajaran({
    required this.token,
    required this.tahun,
    required this.semester,
  });

  @override
  List<Object?> get props => [tahun, semester];
}

class UpdateTahunPelajaran extends TahunPelajaranEvent {
  final String token;
  final int id;
  final String? tahun;
  final String? semester;

  const UpdateTahunPelajaran({
    required this.token,
    required this.id,
    this.tahun,
    this.semester,
  });

  @override
  List<Object?> get props => [id, tahun, semester];
}

class DeleteTahunPelajaran extends TahunPelajaranEvent {
  final String token;
  final int id;

  const DeleteTahunPelajaran({required this.id, required this.token});

  @override
  List<Object?> get props => [id];
}