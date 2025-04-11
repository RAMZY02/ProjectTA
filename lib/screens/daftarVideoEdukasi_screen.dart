import 'package:flutter/material.dart';

import 'detailVideo_screen.dart';

class DaftarVideoEdukasiScreen extends StatelessWidget {
  final String kelas;

  const DaftarVideoEdukasiScreen({super.key, required this.kelas});

  // Data video edukasi (biasanya dari API/database)
  final List<Map<String, dynamic>> semuaVideo = const [
    {
      'judul': 'Matematika Dasar - Aljabar',
      'kelas': 'Kelas 7',
      'durasi': '15:30',
      'guru': 'Budi Santoso, S.Pd',
      'thumbnail': 'https://i.ytimg.com/vi/abc123/mqdefault.jpg',
      'url': 'https://example.com/video1'
    },
    {
      'judul': 'IPA - Sistem Pencernaan',
      'kelas': 'Kelas 8',
      'durasi': '22:45',
      'guru': 'Dewi Anggraeni, S.Pd',
      'thumbnail': 'https://i.ytimg.com/vi/def456/mqdefault.jpg',
      'url': 'https://example.com/video2'
    },
    {
      'judul': 'Bahasa Inggris - Simple Present Tense',
      'kelas': 'Kelas 7',
      'durasi': '18:20',
      'guru': 'John Smith, S.Pd',
      'thumbnail': 'https://i.ytimg.com/vi/ghi789/mqdefault.jpg',
      'url': 'https://example.com/video3'
    },
    {
      'judul': 'Bahasa Inggris - Simple Present Tense',
      'kelas': 'Kelas 9',
      'durasi': '18:20',
      'guru': 'John Smith, S.Pd',
      'thumbnail': 'https://i.ytimg.com/vi/ghi789/mqdefault.jpg',
      'url': 'https://example.com/video3'
    },
    {
      'judul': 'Bahasa Inggris - Simple Present Tense 2',
      'kelas': 'Kelas 7',
      'durasi': '18:20',
      'guru': 'John Smith, S.Pd',
      'thumbnail': 'https://i.ytimg.com/vi/ghi789/mqdefault.jpg',
      'url': 'https://example.com/video3'
    },
    {
      'judul': 'Bahasa Inggris - Simple Present Tense 3',
      'kelas': 'Kelas 7',
      'durasi': '18:20',
      'guru': 'John Smith, S.Pd',
      'thumbnail': 'https://i.ytimg.com/vi/ghi789/mqdefault.jpg',
      'url': 'https://example.com/video3'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter video berdasarkan kelas yang dipilih
    final videoKelas = semuaVideo.where((video) => video['kelas'] == kelas).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Video Edukasi $kelas',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: videoKelas.isEmpty
          ? const Center(
        child: Text(
          'Tidak ada video edukasi untuk kelas ini',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videoKelas.length,
        itemBuilder: (context, index) {
          final video = videoKelas[index];
          // Di dalam ListView.builder, pada bagian itemBuilder:
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailVideoScreen(
                    video: video,
                    semuaVideo: semuaVideo,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thumbnail video
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      image: DecorationImage(
                        image: NetworkImage(video['thumbnail']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 50,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video['judul'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 16),
                            const SizedBox(width: 4),
                            Text(video['durasi']),
                            const Spacer(),
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text(video['guru']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}