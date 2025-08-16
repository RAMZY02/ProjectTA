import 'package:project_ta/models/hadiah_model.dart';

abstract class KuponEvent{}

class InitialKupon extends KuponEvent {}

class FetchKupon extends KuponEvent{
  final String token;
  final int userId;

  FetchKupon({required this.token, required this.userId});
}

class FetchAllKupon extends KuponEvent{
  final String token;

  FetchAllKupon({required this.token});
}

class ClaimKupon extends KuponEvent{
  final String token;
  final int idKupon;

  ClaimKupon({required this.token, required this.idKupon});
}

class CreateKupon extends KuponEvent{
  final String token;
  final HadiahModel hadiah;
  final int userId;

  CreateKupon({required this.token, required this.hadiah, required this.userId});
}