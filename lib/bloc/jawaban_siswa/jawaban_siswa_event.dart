
abstract class JawabanSiswaEvent{}

class Initial extends JawabanSiswaEvent {}

class FetchJawabanSiswa extends JawabanSiswaEvent{
  final String token;
  final int userId;
  final int ujianId;
  final int soalId;

  FetchJawabanSiswa({required this.token, required this.userId, required this.ujianId, required this.soalId});
}


class CreateJawabanSiswa extends JawabanSiswaEvent{
  final String token;
  final int ujianId;
  final int soalId;
  final int urutan;
  final String jawaban;
  final int nilai;

  CreateJawabanSiswa({required this.token, required this.ujianId, required this.soalId, required this.urutan, required this.jawaban, required this.nilai});
}

class UpdateJawabanSiswa extends JawabanSiswaEvent{
  final String token;
  final int userId;
  final int ujianId;
  final int soalId;
  final String jawaban;
  final int nilai;

  UpdateJawabanSiswa({required this.token, required this.userId, required this.ujianId, required this.soalId, required this.jawaban, required this.nilai});
}