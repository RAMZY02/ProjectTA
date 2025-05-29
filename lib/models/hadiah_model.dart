class HadiahModel {
  final int id;
  final String nama;
  final int poin;
  final int stok;
  final String link_gambar;
  final String kategori;

  HadiahModel({
    required this.id,
    required this.nama,
    required this.poin,
    required this.stok,
    required this.link_gambar,
    required this.kategori,
  });

  factory HadiahModel.fromJson(Map<String, dynamic> json) {
    return HadiahModel(
      id: json['id'],
      nama: json['nama'],
      poin: json['poin'] ?? 0,
      stok: json['stok'] ?? 0,
      link_gambar: json['link_gambar'] ?? '-',
      kategori: json['kategori'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'poin': poin,
      'stok': stok,
      'link_gambar': link_gambar,
      'kategori': kategori,
    };
  }
}