class HistoryTugasModel {
  final int id;
  final int idPengumpulanTugas;
  final DateTime timestamps;

  HistoryTugasModel({
    required this.id,
    required this.idPengumpulanTugas,
    required this.timestamps,
  });

  factory HistoryTugasModel.fromJson(Map<String, dynamic> json) {
    return HistoryTugasModel(
      id: json['id'],
      idPengumpulanTugas: json['id_pengumpulan_tugas'],
      timestamps: DateTime.parse(json['timestamps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pengumpulan_tugas': idPengumpulanTugas,
      'timestamps': timestamps.toIso8601String(),
    };
  }
}