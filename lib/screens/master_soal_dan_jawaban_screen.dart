import 'package:flutter/material.dart';
import 'package:project_ta/screens/insert_soal_dan_jawaban_screen.dart';

class MasterSoalDanJawabanScreen extends StatefulWidget {
  final Map<String, dynamic> ujian;

  const MasterSoalDanJawabanScreen({
    super.key,
    required this.ujian,
  });

  @override
  State<MasterSoalDanJawabanScreen> createState() => _MasterSoalDanJawabanScreenState();
}

class _MasterSoalDanJawabanScreenState extends State<MasterSoalDanJawabanScreen> {
  List<Map<String, dynamic>> _soal_jawaban = [
    {
      'id': 1,
      "id_ujian": "1",
      'soal': 'Ibu kota Indonesia',
      'opsi1': 'Jakarta',
      'opsi2': 'Bandung',
      'opsi3': 'Thailand',
      'opsi4': 'Korea',
      'opsi5': 'China',
      'jawaban': 'Jakarta',
      "tipe": "Pilihan Ganda",
      "pembahasan": "Jakarta adalah ibukota Indonesia sejak tahun 1946",
      "link_video": "-",
      "link_gambar": "-",
      "link_audio": "-",
      "link_file": "-"
    },
    {
      'id': 2,
      "id_ujian": "1",
      'soal': '2 + 2 = ?',
      'opsi1': '',
      'opsi2': '',
      'opsi3': '',
      'opsi4': '',
      'opsi5': '',
      'jawaban': '4',
      "tipe": "Isian",
      "pembahasan": "Penjumlahan dasar",
      "link_video": "math_video.mp4",
      "link_gambar": "-",
      "link_audio": "-",
      "link_file": "-"
    },
  ];

  @override
  void initState() {
    super.initState();
    _soal_jawaban = _soal_jawaban.where((soal) => soal['id_ujian'] == widget.ujian['id'].toString()).toList();
  }

  void _deleteSoal(int id) {
    setState(() {
      _soal_jawaban.removeWhere((soal) => soal['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Soal berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soal - ${widget.ujian['nama']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Soal'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsertSoalDanJawabanScreen(
                        idUjian: widget.ujian['id'],
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _soal_jawaban.add(result);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Tipe')),
                      DataColumn(label: Text('Soal')),
                      DataColumn(label: Text('Opsi A')),
                      DataColumn(label: Text('Opsi B')),
                      DataColumn(label: Text('Opsi C')),
                      DataColumn(label: Text('Opsi D')),
                      DataColumn(label: Text('Opsi E')),
                      DataColumn(label: Text('Jawaban')),
                      DataColumn(label: Text('Pembahasan')),
                      DataColumn(label: Text('Link Video')),
                      DataColumn(label: Text('Link Gambar')),
                      DataColumn(label: Text('Link File')),
                      DataColumn(label: Text('Link Audio')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _soal_jawaban.map((soal) {
                      return DataRow(
                        cells: [
                          DataCell(Text(soal['id'].toString())),
                          DataCell(Text(soal['tipe'])),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(soal['soal']),
                            ),
                          ),
                          // Show "-" for options if not Pilihan Ganda
                          DataCell(Text(soal['tipe'] == 'Pilihan Ganda' ? soal['opsi1'] : '-')),
                          DataCell(Text(soal['tipe'] == 'Pilihan Ganda' ? soal['opsi2'] : '-')),
                          DataCell(Text(soal['tipe'] == 'Pilihan Ganda' ? soal['opsi3'] : '-')),
                          DataCell(Text(soal['tipe'] == 'Pilihan Ganda' ? soal['opsi4'] : '-')),
                          DataCell(Text(soal['tipe'] == 'Pilihan Ganda' ? soal['opsi5'] : '-')),
                          DataCell(Text(soal['jawaban'])),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(soal['pembahasan']),
                            ),
                          ),
                          DataCell(Text(soal['link_video'] != null && soal['link_video'] != '-' ? soal['link_video'] : '-')),
                          DataCell(Text(soal['link_gambar'] != null && soal['link_gambar'] != '-' ? soal['link_gambar'] : '-')),
                          DataCell(Text(soal['link_file'] != null && soal['link_file'] != '-' ? soal['link_file'] : '-')),
                          DataCell(Text(soal['link_audio'] != null && soal['link_audio'] != '-' ? soal['link_audio'] : '-')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InsertSoalDanJawabanScreen(
                                          soalData: soal,
                                          isEdit: true,
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        final index = _soal_jawaban.indexWhere((s) => s['id'] == soal['id']);
                                        if (index != -1) {
                                          _soal_jawaban[index] = result;
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteSoal(soal['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}