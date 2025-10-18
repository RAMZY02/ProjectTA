// models/mapel_status_model.dart
class MapelStatusModel {
  final String mapel;
  final bool terkirim;
  final int jumlahSiswa;
  final int jumlahTerkirim;

  MapelStatusModel({
    required this.mapel,
    required this.terkirim,
    required this.jumlahSiswa,
    required this.jumlahTerkirim,
  });
}