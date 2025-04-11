import 'package:flutter/material.dart';
import 'package:project_ta/models/video_model.dart';
import 'package:project_ta/screens/detailVideo_screen.dart';

class RekomendasiVideoScreen extends StatelessWidget {
  final List<Video> videos;
  final String userKelas;

  const RekomendasiVideoScreen({
    super.key,
    required this.videos,
    required this.userKelas,
  });

  @override
  Widget build(BuildContext context) {
    // Filter video berdasarkan kelas user
    final recommendedVideos = videos.where((v) => v.grade == userKelas).toList()
      ..sort((a, b) => b.likesCount.compareTo(a.likesCount));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rekomendasi untuk $userKelas',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: recommendedVideos.isEmpty
          ? const Center(
        child: Text('Tidak ada rekomendasi video untuk kelas ini'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendedVideos.length,
        itemBuilder: (context, index) {
          final video = recommendedVideos[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailVideoScreen(
                      video: {
                        'judul': video.title,
                        'kelas': video.grade,
                        'durasi': video.duration,
                        'guru': video.teacher,
                        'thumbnail': video.thumbnail,
                        'url': 'https://example.com/video${video.id}',
                        'views': video.views,
                        'likes': video.likes,
                        'subject': video.subject,
                      },
                      semuaVideo: videos.map((v) => {
                        'judul': v.title,
                        'kelas': v.grade,
                        'durasi': v.duration,
                        'guru': v.teacher,
                        'thumbnail': v.thumbnail,
                        'url': 'https://example.com/video${v.id}',
                        'views': v.views,
                        'likes': v.likes,
                        'subject': v.subject,
                      }).toList(),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        video.thumbnail,
                        width: 100,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${video.subject} • ${video.grade}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.thumb_up_alt_outlined,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                video.likes,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.remove_red_eye_outlined,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                video.views,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
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