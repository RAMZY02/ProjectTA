abstract class HistoryUjianEvent{}

class InitialHistoryUjian extends HistoryUjianEvent {}

class FetchHistoryUjian extends HistoryUjianEvent{
  final String token;
  final int userId;

  FetchHistoryUjian({required this.token, required this.userId});
}

class FetchHistoryUjianSiswa extends HistoryUjianEvent{
  final String token;
  final int userId;

  FetchHistoryUjianSiswa({required this.token, required this.userId});
}

class CreateHistoryUjian extends HistoryUjianEvent{
  final String token;
  final int userId;
  final int ujianId;
  final int nilai;

  CreateHistoryUjian({required this.token, required this.userId, required this.ujianId, required this.nilai});
}

class UpdateHistoryUjian extends HistoryUjianEvent{
  final String token;
  final int userId;
  final int ujianId;
  final String kehadiran;
  final String selesai;
  final int nilai;
  final String diperiksa;

  UpdateHistoryUjian({required this.token, required this.userId, required this.ujianId, required this.kehadiran, required this.selesai, required this.nilai, required this.diperiksa});
}