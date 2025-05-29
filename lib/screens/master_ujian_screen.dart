import 'package:flutter/material.dart';
import 'package:project_ta/screens/insert_ujian_screen.dart';
import 'package:project_ta/screens/master_soal_dan_jawaban_screen.dart'; // Import the soal screen

class MasterUJianScreen extends StatefulWidget {
  const MasterUJianScreen({super.key});

  @override
  State<MasterUJianScreen> createState() => _MasterUJianScreenState();
}

class _MasterUJianScreenState extends State<MasterUJianScreen> {
  final List<Map<String, dynamic>> _ujian = [
    {
      'id': 1,
      'nama': 'Matematika - Kelas 7',
      "tipe": "Ujian Harian",
      "waktu": "01:30:00",
      "tanggal": "15-03-2024",
      "mulai": "08.00",
      "selesai": "09.30",
      "jumlah_soal": "25",
      "guru": "Budi Santoso, S.Pd"
    },
    {
      'id': 2,
      'nama': 'Matematika - Kelas 8',
      "tipe": "Ujian Harian",
      "waktu": "01:30:00",
      "tanggal": "15-03-2024",
      "mulai": "08.00",
      "selesai": "09.30",
      "jumlah_soal": "25",
      "guru": "uda Santoso, S.Pd"
    },
  ];

  void _deleteUjian(int id) {
    setState(() {
      _ujian.removeWhere((ujian) => ujian['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ujian deleted successfully')),
    );
  }

  void _navigateToSoalScreen(Map<String, dynamic> ujian) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasterSoalDanJawabanScreen(ujian: ujian),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Ujian'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InsertUjianScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Tipe')),
                  DataColumn(label: Text('Waktu')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Mulai')),
                  DataColumn(label: Text('Selesai')),
                  DataColumn(label: Text('Jumlah Soal')),
                  DataColumn(label: Text('Guru')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _ujian.map((ujian) {
                  return DataRow(
                    onSelectChanged: (_) => _navigateToSoalScreen(ujian),
                    cells: [
                      DataCell(Text(ujian['id'].toString())),
                      DataCell(Text(ujian['nama'])),
                      DataCell(Text(ujian['tipe'])),
                      DataCell(Text(ujian['waktu'])),
                      DataCell(Text(ujian['tanggal'])),
                      DataCell(Text(ujian['mulai'])),
                      DataCell(Text(ujian['selesai'])),
                      DataCell(Text(ujian['jumlah_soal'])),
                      DataCell(Text(ujian['guru'])),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InsertUjianScreen(
                                      ujianData: ujian,
                                      isEdit: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUjian(ujian['id']),
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
        ],
      ),
    );
  }
}