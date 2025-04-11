import 'package:flutter/material.dart';
import 'package:project_ta/screens/detailUjian_screen.dart';

class UjianScreen extends StatelessWidget {
  const UjianScreen({super.key});

  final List<Map<String, dynamic>> listUjian = const [
    {
      'title': 'Matematika - Kelas 7',
      'date': '15 Maret 2024',
      'time': '08.00 - 09.30 WIB',
      'questions': 25,
      'duration': '90 menit',
      'teacher': 'Budi Santoso, S.Pd',
      'description': 'Ujian tengah semester untuk materi aljabar dan geometri dasar'
    },
    {
      'title': 'IPA - Kelas 8',
      'date': '16 Maret 2024',
      'time': '10.00 - 11.30 WIB',
      'questions': 30,
      'duration': '90 menit',
      'teacher': 'Dewi Anggraeni, S.Pd',
      'description': 'Ujian tengah semester untuk materi sistem pencernaan dan pernapasan'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              "Daftar Ujian",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF1976D2),
            elevation: 4,
            iconTheme: const IconThemeData(color: Colors.white),
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            expandedHeight: 50,
            floating: false,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final ujian = listUjian[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      ujian['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(ujian['date']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(ujian['time']),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailUjianScreen(ujian: ujian),
                        ),
                      );
                    },
                  ),
                );
              },
              childCount: listUjian.length,
            ),
          ),
        ],
      ),
    );
  }
}