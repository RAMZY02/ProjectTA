import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:project_ta/screens/detail_video_screen.dart';
import 'package:project_ta/widgets/video_thumbnail_grid_card.dart';

class TopVideoScreen extends StatelessWidget {
  final List<VideoEdukasiModel> videos;

  const TopVideoScreen({super.key, required this.videos});

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
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Menghitung jumlah kolom berdasarkan lebar layar
          final screenWidth = constraints.maxWidth;
          int crossAxisCount;

          crossAxisCount =  (screenWidth / 150).round();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.45,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            padding: const EdgeInsets.all(8),
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
          );
        },
      ),
    );
  }
}