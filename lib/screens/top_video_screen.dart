import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:project_ta/screens/detail_video_screen.dart';
import 'package:project_ta/widgets/video_thumbnail_grid_card.dart';

import '../widgets/video_thumbnail_card.dart';

class TopVideoScreen extends StatelessWidget {
  final List<VideoEdukasiModel> videos;

  TopVideoScreen({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    final sortedVideos = List<VideoEdukasiModel>.from(videos)
      ..sort((a, b) => b.likes.compareTo(a.likes));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Video Edukasi',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey, // Warna status bar abu-abu
          statusBarIconBrightness: Brightness.light, // Icon status bar putih
          statusBarBrightness: Brightness.dark, // Untuk Android
        ),
      ),
      body: Container(
        margin: EdgeInsets.zero,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.45,
          ),
          itemCount: sortedVideos.length,
          itemBuilder: (context, index) {
            return VideoThumbnailGridCard(
              video: sortedVideos[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailVideoScreen(
                      video: sortedVideos[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic> videoToMap(VideoEdukasiModel video) {
    return {
      'judul': video.judul,
      'kelas': video.kelas,
      'url': 'asset://assets/videos/BELAJAR_INTEGRAL_DARI_DASAR_DALAM_12_MENIT.mp4',
      'views': video.views,
      'likes': video.likes,
      'subject': video.mata_pelajaran,
    };
  }
}