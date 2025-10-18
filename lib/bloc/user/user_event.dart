abstract class UserEvent{}

class Initial extends UserEvent {}

class LoadUser extends UserEvent{
  final int id;
  final String username;
  final String kelas;
  final String agama;
  final String role;
  final String nomor_ortu;
  final int id_mapel;
  final String mapel;
  final String token;
  final int poin;
  final String profpic;
  final String email;

  LoadUser({required this.id, required this.username, required this.kelas, required this.agama, required this.role, required this.nomor_ortu, required this.id_mapel, required this.mapel, required this.token, required this.poin, required this.profpic, required this.email});
}

class UpdatePoin extends UserEvent {
  String token;
  int poin;

  UpdatePoin({required this.token, required this.poin});
}

class UpdateProfpic extends UserEvent{
  String token;
  String profpic;

  UpdateProfpic({required this.token, required this.profpic});
}

class ChangePassword extends UserEvent{
  String token;
  String currentPassword;
  String newPassword;

  ChangePassword({required this.token, required this.currentPassword, required this.newPassword});
}