import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/insert_video_edukasi_screen.dart';

class VideoEdukasiGuruScreen extends StatelessWidget {
  const VideoEdukasiGuruScreen({super.key});

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Bahasa Indonesia')) return Icons.language;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('TIK')) return Icons.computer;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Bahasa Indonesia')) return Colors.red;
    if (title.contains('IPA')) return Colors.purple;
    if (title.contains('Matematika')) return Colors.blue;
    if (title.contains('TIK')) return Colors.brown;
    return Colors.grey; // Default
  }

  final List<String> mata_pelajaran = const [
    'Bahasa Indonesia',
    'IPA',
    'Matematika',
    'TIK'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ini yang menghilangkan tombol back
        title: const Text(
          "Mata Pelajaran",
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
      body: ListView.builder(
          itemCount: mata_pelajaran.length,
          itemBuilder: (context, index) {
            final mapel = mata_pelajaran[index];
            return Card(
              margin: const EdgeInsets.all(12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pushNamed(
                      context,
                      "/daftar-video-guru",
                      arguments: mapel
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
                          color: _getSubjectColor(mapel).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getSubjectIcon(mapel),
                          color: _getSubjectColor(mapel),
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Konten Ujian
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mapel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                  fontSize: 16
                              ),
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
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertVideoEdukasiScreen(),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}