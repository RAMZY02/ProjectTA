abstract class UserEvent{}

class Initial extends UserEvent {}

class LoadUser extends UserEvent{
  final int id;
  final String username;
  final String kelas;
  final String role;
  final String token;
  final int poin;
  final String profpic;
  final String email;
  final DateTime timestamps;

  LoadUser({required this.id, required this.username, required this.kelas, required this.role, required this.token, required this.poin, required this.profpic, required this.email, required this.timestamps});
}

class UpdatePoin extends UserEvent {
  String token;
  int poin;

  UpdatePoin({required this.token, required this.poin});
}