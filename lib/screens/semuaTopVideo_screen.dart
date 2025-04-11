import 'package:flutter/material.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/video_model.dart';
import 'package:project_ta/screens/detailVideo_screen.dart';

class SemuaTopVideosScreen extends StatelessWidget {
  final List<Video> videos;

  SemuaTopVideosScreen({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    // Urutkan video berdasarkan likes (terbanyak ke terkecil)
    final sortedVideos = List<Video>.from(videos)
      ..sort((a, b) => b.likesCount.compareTo(a.likesCount));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semua Video Teratas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedVideos.length,
        itemBuilder: (context, index) {
          final video = sortedVideos[index];
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
                      semuaVideo: sortedVideos.map((v) => {
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
                    // Thumbnail dengan border radius
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${video.subject} • ${video.grade}',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 16,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.likes,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 16,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.views,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: secondaryTextColor,
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