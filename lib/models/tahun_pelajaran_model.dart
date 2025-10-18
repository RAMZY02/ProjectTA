class TahunPelajaranModel {
  final int id;
  final String tahun;
  final String semester;

  TahunPelajaranModel({
    required this.id,
    required this.tahun,
    required this.semester,
  });

  // Factory method untuk membuat object dari JSON
  factory TahunPelajaranModel.fromJson(Map<String, dynamic> json) {
    return TahunPelajaranModel(
      id: json['id'],
      tahun: json['tahun'],
      semester: json['semester'],
    );
  }

  // Method untuk mengubah object menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tahun': tahun,
      'semester': semester,
    };
  }
}