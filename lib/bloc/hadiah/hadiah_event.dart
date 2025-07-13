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

class AddHadiah extends HadiahEvent {
  String token;
  String nama;
  int poin;
  int stok;
  String linkGambar;
  String kategori;
  String keyStatus;

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
  String token;
  int hadiahId;
  String? nama;
  int? poin;
  int? stok;
  String? linkGambar;
  String? kategori;
  String? keyStatus;

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
  String token;
  int hadiahId; // Corresponds to req.params.id

  DeleteHadiah({
    required this.token,
    required this.hadiahId,
  });
}