import 'package:flutter/material.dart';
import 'package:project_ta/screens/daftar_siswa_screen.dart';

class KoreksiScreen extends StatelessWidget {
  const KoreksiScreen({super.key});

  final List<Map<String, dynamic>> listUjian = const [
    {
      'id': '1',
      'title': 'Matematika - Kelas 7',
      'date': '15 Maret 2024',
      'time': '08.00 - 09.30 WIB',
      'questions': 25,
      'duration': '90 menit',
      'teacher': 'Budi Santoso, S.Pd',
      'description': 'Ujian tengah semester untuk materi aljabar dan geometri dasar'
    },
    {
      'id': '2',
      'title': 'IPA - Kelas 8',
      'date': '16 Maret 2024',
      'time': '10.00 - 11.30 WIB',
      'questions': 30,
      'duration': '90 menit',
      'teacher': 'Dewi Anggraeni, S.Pd',
      'description': 'Ujian tengah semester untuk materi sistem pencernaan dan pernapasan'
    },
    {
      'id': '3',
      'title': 'Bahasa Indonesia - Kelas 9',
      'date': '17 Maret 2024',
      'time': '11.00 - 12.30 WIB',
      'questions': 30,
      'duration': '90 menit',
      'teacher': 'Dewa Anggra, S.Pd',
      'description': 'Ujian tengah semester untuk materi sistem pencernaan dan pernapasan'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Ujian'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listUjian.length,
        itemBuilder: (context, index) {
          final ujian = listUjian[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DaftarSiswaScreen(ujian: ujian),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ujian['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Tanggal: ${ujian['date']}'),
                    Text('Waktu: ${ujian['time']}'),
                    Text('Durasi: ${ujian['duration']}'),
                    Text('Jumlah Soal: ${ujian['questions']}'),
                    const SizedBox(height: 8),
                    Text(
                      ujian['description'],
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}