abstract class HistoryTugasEvent {}

class InitialHistoryTugas extends HistoryTugasEvent {}

class FetchHistoryTugas extends HistoryTugasEvent {
  final String token;

  FetchHistoryTugas({required this.token});
}

class FetchHistoryTugasSiswa extends HistoryTugasEvent {
  final String token;
  final int userId;
  final int tugasId;

  FetchHistoryTugasSiswa({required this.token, required this.userId, required this.tugasId});
}

class CreateHistoryTugas extends HistoryTugasEvent {
  final String token;
  final int userId;
  final int tugasId;

  CreateHistoryTugas({
    required this.token,
    required this.userId,
    required this.tugasId,
  });
}

class UpdateHistoryTugas extends HistoryTugasEvent {
  final String token;
  final int pengumpulanTugasId;
  final DateTime timestamps;

  UpdateHistoryTugas({
    required this.token,
    required this.pengumpulanTugasId,
    required this.timestamps,
  });
}