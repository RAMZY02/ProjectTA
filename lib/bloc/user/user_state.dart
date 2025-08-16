abstract class UserState {}

class UserInitial extends UserState {}

class UserLoaded extends UserState{

  final int id;
  final String username;
  final String kelas;
  final String role;
  final String mapel;
  final String nomor_ortu;
  final String token;
  final int poin;
  final String profpic;
  final String email;
  final DateTime timestamps;

  UserLoaded({required this.id, required this.username, required this.kelas, required this.role, required this.nomor_ortu, required this.mapel, required this.token, required this.poin, required this.profpic, required this.email, required this.timestamps});
}

class UserError extends UserState{
  String message;

  UserError({required this.message});
}