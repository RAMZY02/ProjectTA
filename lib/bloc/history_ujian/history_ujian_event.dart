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