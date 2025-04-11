import 'package:flutter/material.dart';
import 'package:project_ta/screens/soalUjian_screen.dart';

class DetailUjianScreen extends StatelessWidget {
  final Map<String, dynamic> ujian;

  const DetailUjianScreen({super.key, required this.ujian});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Ujian",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ujian['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const Divider(height: 24, thickness: 1),
                          _buildDetailRow(Icons.calendar_today, 'Tanggal', ujian['date']),
                          _buildDetailRow(Icons.access_time, 'Waktu', ujian['time']),
                          _buildDetailRow(Icons.timer, 'Durasi', ujian['duration']),
                          _buildDetailRow(Icons.person, 'Pengajar', ujian['teacher']),
                          _buildDetailRow(Icons.format_list_numbered, 'Jumlah Soal', '${ujian['questions']} soal'),
                          const SizedBox(height: 16),
                          const Text(
                            'Deskripsi:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ujian['description'],
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Petunjuk Ujian:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('1. Baca soal dengan teliti'),
                          Text('2. Waktu ujian tidak dapat dihentikan'),
                          Text('3. Jawaban tidak dapat diubah setelah dikirim'),
                          Text('4. Dilarang bekerja sama dengan peserta lain'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SoalUjianScreen(
                      soalList: [
                        {
                          'type': 'pilihan_ganda',
                          'pertanyaan': 'Apa ibukota Indonesia?',
                          'pilihan': ['Jakarta', 'Bandung', 'Surabaya', 'Medan', 'Lombok'],
                          'jawaban_benar': 0,
                        },
                        {
                          'type': 'essay',
                          'pertanyaan': 'Jelaskan teori evolusi Darwin!',
                        },
                        {
                          'type' : 'upload_file',
                          'pertanyaan' : 'Uploadlah video tarian kalian sesuai dengan yang pernah diajarkan dikelas!'
                        }
                      ],
                      durationMinutes: 120,
                    ),
                  ),
                );
              },
              child: const Text(
                'MULAI UJIAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}