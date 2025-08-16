abstract class MengikutiUjianEvent{}

class Initialize extends MengikutiUjianEvent {}

class FetchMengikutiUjian extends MengikutiUjianEvent{
  final String token;
  final int userId;

  FetchMengikutiUjian({required this.token, required this.userId});
}

class FetchMengikutiUjianById extends MengikutiUjianEvent{
  final String token;
  final int userId;
  final int ujianId;

  FetchMengikutiUjianById({required this.token, required this.userId, required this.ujianId});
}

class CreateMengikutiUjian extends MengikutiUjianEvent{
  final String token;
  final int userId;
  final int ujianId;

  CreateMengikutiUjian({required this.token, required this.userId, required this.ujianId});
}

class UpdateMengikutiUjian extends MengikutiUjianEvent{
  final String token;
  final int userId;
  final int ujianId;

  UpdateMengikutiUjian({required this.token, required this.userId, required this.ujianId});
}