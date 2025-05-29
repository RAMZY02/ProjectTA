import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/insert_ujian_screen.dart';
import 'package:project_ta/screens/membuat_soal_screen.dart';

class SoalScreen extends StatelessWidget {
  const SoalScreen({super.key});

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('Bahasa')) return Icons.language;
    if (title.contains('Sejarah')) return Icons.history;
    if (title.contains('IPS')) return Icons.public;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Matematika')) return Colors.blue;
    if (title.contains('IPA')) return Colors.green;
    if (title.contains('Bahasa')) return Colors.purple;
    if (title.contains('Sejarah')) return Colors.orange;
    if (title.contains('IPS')) return Colors.brown;
    return Colors.grey; // Default
  }

  final List<Map<String, dynamic>> listUjian = const [
    {
      'id' : '1',
      'title': 'Matematika - Kelas 7',
      'date': '15 Maret 2024',
      'time': '08.00 - 09.30 WIB',
      'questions': 25,
      'duration': '90 menit',
      'teacher': 'Budi Santoso, S.Pd',
      'description': 'Ujian tengah semester untuk materi aljabar dan geometri dasar'
    },
    {
      'id' : '2',
      'title': 'IPA - Kelas 8',
      'date': '16 Maret 2024',
      'time': '10.00 - 11.30 WIB',
      'questions': 30,
      'duration': '90 menit',
      'teacher': 'Dewi Anggraeni, S.Pd',
      'description': 'Ujian tengah semester untuk materi sistem pencernaan dan pernapasan'
    },
    {
      'id' : '3',
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
        title: const Text(
          "Daftar Ujian",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: listUjian.isEmpty
          ? const Center(
        child: Text('Belum ada ujian yang tersedia'),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listUjian.length,
              itemBuilder: (context, index) {
                final ujian = listUjian[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembuatSoalScreen(ujian: ujian),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Logo Mata Pelajaran
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getSubjectColor(ujian['title']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getSubjectIcon(ujian['title']),
                              color: _getSubjectColor(ujian['title']),
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Konten Ujian
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ujian['title'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D47A1),
                                      fontSize: 14
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      ujian['date'],
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      ujian['time'],
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertUjianScreen(),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}