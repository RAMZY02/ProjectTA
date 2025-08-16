import 'package:equatable/equatable.dart';
import 'package:project_ta/models/hadiah_model.dart';

abstract class HadiahEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Inits extends HadiahEvent {}

class FetchHadiah extends HadiahEvent {
  final String token;

  FetchHadiah({required this.token});
}

class TukarHadiah extends HadiahEvent{
  final String token;
  final int userId;
  final int hadiahId;
  final List<HadiahModel> hadiah;

  TukarHadiah({required this.token, required this.userId, required this.hadiahId, required this.hadiah});
}

class AddHadiah extends HadiahEvent {
  final String token;
  final String nama;
  final int poin;
  final int stok;
  final String linkGambar;
  final String kategori;
  final String keyStatus;

  AddHadiah({
    required this.token,
    required this.nama,
    required this.poin,
    required this.stok,
    this.linkGambar = '-',
    this.kategori = '-',
    this.keyStatus = 'active',
  });
}

class UpdateHadiah extends HadiahEvent {
  final String token;
  final int hadiahId;
  final String? nama;
  final int? poin;
  final int? stok;
  final String? linkGambar;
  final String? kategori;
  final String? keyStatus;

  UpdateHadiah({
    required this.token,
    required this.hadiahId,
    this.nama,
    this.poin,
    this.stok,
    this.linkGambar,
    this.kategori,
    this.keyStatus,
  });
}

class DeleteHadiah extends HadiahEvent {
  final String token;
  final int hadiahId; // Corresponds to req.params.id

  DeleteHadiah({
    required this.token,
    required this.hadiahId,
  });
}