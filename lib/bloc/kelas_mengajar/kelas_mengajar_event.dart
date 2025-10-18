import 'package:equatable/equatable.dart';

abstract class KelasMengajarEvent extends Equatable {
  const KelasMengajarEvent();

  @override
  List<Object?> get props => [];
}

// Event untuk mengambil semua kelas mengajar
class FetchAllKelasMengajar extends KelasMengajarEvent {
  final String token;

  const FetchAllKelasMengajar({required this.token});

  @override
  List<Object?> get props => [token];
}

// Event untuk mengambil kelas mengajar by ID
class FetchKelasMengajarById extends KelasMengajarEvent {
  final int id;
  final String token;

  const FetchKelasMengajarById({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

// Event untuk mengambil kelas mengajar by User ID
class FetchKelasMengajarByUserId extends KelasMengajarEvent {
  final int idUser;
  final String token;

  const FetchKelasMengajarByUserId({required this.idUser, required this.token});

  @override
  List<Object?> get props => [idUser, token];
}

// Event untuk membuat kelas mengajar baru
class CreateKelasMengajar extends KelasMengajarEvent {
  final int idUser;
  final String kelas;
  final String? keyStatus;
  final String token;

  const CreateKelasMengajar({
    required this.idUser,
    required this.kelas,
    this.keyStatus,
    required this.token,
  });

  @override
  List<Object?> get props => [idUser, kelas, keyStatus, token];
}

// Event untuk mengupdate kelas mengajar
class UpdateKelasMengajar extends KelasMengajarEvent {
  final int id;
  final int? idUser;
  final String? kelas;
  final String? keyStatus;
  final String token;

  const UpdateKelasMengajar({
    required this.id,
    this.idUser,
    this.kelas,
    this.keyStatus,
    required this.token,
  });

  @override
  List<Object?> get props => [id, idUser, kelas, keyStatus, token];
}

// Event untuk menghapus kelas mengajar
class DeleteKelasMengajar extends KelasMengajarEvent {
  final int id;
  final String token;

  const DeleteKelasMengajar({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}