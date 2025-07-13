import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:project_ta/screens/detail_video_screen.dart';
import 'package:project_ta/widgets/list_rekomendasi.dart';
import 'package:project_ta/widgets/list_semua_rekomendasi.dart';

class RekomendasiVideoScreen extends StatelessWidget {
  final List<VideoEdukasiModel> videos;
  final String userKelas;

  const RekomendasiVideoScreen({
    super.key,
    required this.videos,
    required this.userKelas,
  });

  @override
  Widget build(BuildContext context) {
    // Filter video berdasarkan kelas user
    final recommendedVideos = videos.where((v) => v.kelas == userKelas.substring(0, 1)).toList()
      ..sort((a, b) => b.likes.compareTo(a.likes));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rekomendasi untuk Kelas ${userKelas.substring(0, 1)}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
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
      body: recommendedVideos.isEmpty
          ? const Center(
        child: Text('Tidak ada rekomendasi video untuk kelas ini'),
      )
          : ListView.builder(
        itemCount: recommendedVideos.length,
        itemBuilder: (context, index) {
          final video = recommendedVideos[index];
          return ListSemuaRekomendasi(
            video: video,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailVideoScreen(
                    video: video,
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }
}