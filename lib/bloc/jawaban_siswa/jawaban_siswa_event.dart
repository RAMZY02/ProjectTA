import 'package:project_ta/models/hadiah_model.dart';

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
  final HadiahModel hadiah;
  final int userId;

  CreateJawabanSiswa({required this.token, required this.hadiah, required this.userId});
}