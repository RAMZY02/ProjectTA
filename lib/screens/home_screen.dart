import 'package:project_ta/constants/color.dart';
import 'package:project_ta/constants/size.dart';
import 'package:project_ta/screens/notifikasi_screen.dart';
import 'package:project_ta/screens/rekomendasiVideo_screen.dart';
import 'package:project_ta/screens/semuaTopVideo_screen.dart';
import 'package:project_ta/widgets/circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/video_model.dart';
import 'detailVideo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // AppBar sebagai SliverAppBar
            SliverAppBar(
              expandedHeight: 130, // Tinggi AppBar saat expanded
              floating: false,
              pinned: false, // AppBar tidak akan tetap di atas saat scroll
              snap: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Builder(
                  builder: (context) => AppBar(context: context),
                ),
              ),
            ),

            // Konten Body sebagai SliverList
            SliverList(
              delegate: SliverChildListDelegate([
                Body(), // Pindahkan konten Body ke sini
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBar extends StatelessWidget {
  final BuildContext context;

  const AppBar({
    super.key,
    required this.context
  });

  String _getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 11) {
      return "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else if (hour >= 18 && hour < 24) {
      return "Selamat Malam";
    } else {
      return "Ini Waktunya Tidur";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5],
          colors: [
            Color(0xff886ff2),
            Color(0xff6849ef),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo,\n${_getGreeting()}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryLight,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotifikasiScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Row(
            children: [
              Text(
                "Nama_user",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  final List<Video> allVideos = const [
    Video(
      id: '1',
      title: 'Pembahasan Soal Matematika Integral dasar',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '2',
      title: 'Pembahasan Soal Matematika Integral dasar 2',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '3',
      title: 'Pembahasan Soal Matematika Integral dasar 3',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '4',
      title: 'Pembahasan Soal Matematika Integral dasar 4',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '5',
      title: 'Pembahasan Soal Matematika Integral dasar 5',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '6',
      title: 'Pembahasan Soal Matematika Integral dasar 6',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '7',
      title: 'Pembahasan Soal Matematika Integral dasar 7',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '8',
      title: 'Pembahasan Soal Matematika Integral dasar 8',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
    Video(
      id: '9',
      title: 'Pembahasan Soal Matematika Integral dasar 9',
      subject: 'Matematika',
      grade: 'Kelas 7',
      views: '1.2K',
      likes: '245',
      thumbnail: 'https://picsum.photos/200/100?random=1',
      duration: '15:30',
      teacher: 'Budi Santoso, S.Pd',
    ),
  ];

  // Getter untuk video rekomendasi
  List<Video> get rekomendasiVideos {
    return allVideos
        .where((video) => video.grade == "Kelas 7") // Filter berdasarkan kelas user
        .toList()
      ..sort((a, b) => b.likesCount.compareTo(a.likesCount)); // Urutkan berdasarkan likes
  }

  // Ambil 3 video teratas berdasarkan likes
  List<Video> get topVideos {
    final sortedVideos = List<Video>.from(allVideos)
      ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    return sortedVideos.take(3).toList();
  }

  Map<String, dynamic> videoToMap(Video video) {
    return {
      'judul': video.title,
      'kelas': video.grade,
      'durasi': video.duration,
      'guru': video.teacher,
      'thumbnail': video.thumbnail,
      'url': 'asset://assets/videos/BELAJAR_INTEGRAL_DARI_DASAR_DALAM_12_MENIT.mp4',
      'views': video.views,
      'likes': video.likes,
      'subject': video.subject,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bagian Top Video Edukasi
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top Video Edukasi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SemuaTopVideosScreen(videos: allVideos),
                    ),
                  );
                },
                child: const Text("Lihat Semua"),
              ),
            ],
          ),
        ),

        // Tampilkan 3 video teratas
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topVideos.length,
            itemBuilder: (context, index) {
              return VideoThumbnailCard(
                  video: topVideos[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailVideoScreen(
                          video: videoToMap(topVideos[index]),
                          semuaVideo: allVideos.map(videoToMap).toList(),
                        ),
                      ),
                    );
                  },
                );
            },
          ),
        ),

        // Bagian Rekomendasi Lainnya
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Rekomendasi Lainnya",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RekomendasiVideoScreen(
                        videos: allVideos,
                        userKelas: "Kelas 7", // Ganti dengan kelas user sesungguhnya
                      ),
                    ),
                  );
                },
                child: const Text("Lihat Semua"),
              ),
            ],
          ),
        ),

        // List Rekomendasi (max 5 item)
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: rekomendasiVideos.take(5).length, // Ambil maksimal 5 item
          itemBuilder: (context, index) {
            final video = rekomendasiVideos[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    video.thumbnail,
                    width: 100,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  video.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${video.subject} • ${video.grade}',
                      style: TextStyle(
                        fontSize: 12,
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
                            fontSize: 12,
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
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailVideoScreen(
                        video: videoToMap(video),
                        semuaVideo: allVideos.map(videoToMap).toList(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

      ],
    );
  }
}

class VideoThumbnailCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoThumbnailCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(left: 20, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                video.thumbnail,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('${video.subject} • ${video.grade}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 14),
                Text(' ${video.likes}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}