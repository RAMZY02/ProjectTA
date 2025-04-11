import 'package:flutter/material.dart';
import 'daftarVideoEdukasi_screen.dart';

class VideoEdukasiScreen extends StatelessWidget {
  const VideoEdukasiScreen({super.key});

  final List<String> daftarKelas = const [
    'Kelas 7',
    'Kelas 8',
    'Kelas 9'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Kelas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daftarKelas.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.school, color: Color(0xFF0D47A1)),
              title: Text(
                daftarKelas[index],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DaftarVideoEdukasiScreen(kelas: daftarKelas[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}