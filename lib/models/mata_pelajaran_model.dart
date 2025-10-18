class MataPelajaranModel {
  final int id;
  final String mapel;
  final String keyStatus;

  MataPelajaranModel({
    required this.id,
    required this.mapel,
    required this.keyStatus,
  });

  // Factory method untuk membuat object dari JSON
  factory MataPelajaranModel.fromJson(Map<String, dynamic> json) {
    return MataPelajaranModel(
      id: json['id'],
      mapel: json['mapel'],
      keyStatus: json['key_status'],
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mapel': mapel,
      'key_status': keyStatus,
    };
  }
}