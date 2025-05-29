abstract class HistoryUjianEvent{}

class Initial extends HistoryUjianEvent {}

class FetchHistoryUjian extends HistoryUjianEvent{
  final String token;
  final int userId;

  FetchHistoryUjian({required this.token, required this.userId});
}