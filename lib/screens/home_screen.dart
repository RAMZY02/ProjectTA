import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:project_ta/screens/notifikasi_screen.dart';
import 'package:project_ta/screens/rekomendasi_video_screen.dart';
import 'package:project_ta/screens/top_video_screen.dart';
import 'package:project_ta/widgets/list_rekomendasi.dart';
import 'package:project_ta/widgets/video_thumbnail_card.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';
import '../bloc/video_edukasi/video_edukasi_state.dart';
import 'detail_video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

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
    final authState = context.read<AuthBloc>().state;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black.withOpacity(0.2),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Container(
            height: 178,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: kPrimaryColor
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo,\n${_getGreeting()}",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
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
                  )
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: kPrimaryColor
                    ),
                    child: Row(
                      children: [
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, state){
                            if(state is UserLoaded && authState is Authenticated){
                              return Text(
                                state.username,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              );
                            }
                            else{
                              return Text('');
                            }
                          }
                        )
                      ],
                    )
                  )
                ),
              ],
            ),
          )
        ),
          body: BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              return BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
                builder: (context, videoState) {
                  // Handle loading/error states first
                  if (videoState is VideoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (videoState is VideoError) {
                    return Center(child: Text(videoState.message));
                  }

                  // Init fetch videos when authenticated
                  if (authState is Authenticated && userState is UserLoaded && videoState is VideoInitial) {
                    Future.microtask(() {
                      context.read<VideoEdukasiBloc>().add(FetchVideos(token: userState.token, userId: userState.id));
                    });
                  }

                  // Main content when videos are loaded
                  if (videoState is VideoLoaded) {
                    final allVideos = videoState.videos;

                    // Filter rekomendasi videos
                    final rekomendasiVideos = authState is Authenticated && userState is UserLoaded
                        ? (allVideos
                        .where((video) => video.kelas == userState.kelas.substring(0, 1))
                        .toList()
                      ..sort((a, b) => b.likes.compareTo(a.likes)))
                        : [];

                    // Get top videos
                    final sortedVideos = List<VideoEdukasiModel>.from(allVideos);
                    sortedVideos.sort((a, b) => b.likes.compareTo(a.likes));
                    final topVideos = sortedVideos.take(4).toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Top Video Section
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Top Video Edukasi",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopVideoScreen(videos: allVideos),
                                    ),
                                  ),
                                  child: const Text("Lihat Semua"),
                                ),
                              ],
                            ),
                          ),

                          // Top Videos List
                          SizedBox(
                            height: 275,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: topVideos.length,
                              itemBuilder: (context, index) => VideoThumbnailCard(
                                video: topVideos[index],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailVideoScreen(
                                      video: topVideos[index],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Rekomendasi Section
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 10, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Rekomendasi Lainnya",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (authState is Authenticated && userState is UserLoaded) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RekomendasiVideoScreen(
                                            videos: allVideos,
                                            userKelas: userState.kelas,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Lihat Semua"),
                                ),
                              ],
                            ),
                          ),

                          // Rekomendasi List
                          Column(
                            children: rekomendasiVideos
                                .take(5)
                                .map((video) => ListRekomendasi(
                              video: video,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailVideoScreen(
                                    video: video,
                                  ),
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text("Tidak ada data"));
                },
              );
            },
          )
      ),
    );
  }
}