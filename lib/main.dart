import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/mengikuti_ujian/mengikuti_ujian_bloc.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:project_ta/screens/daftar_video_edukasi_guru_screen.dart';
import 'package:project_ta/screens/daftar_video_edukasi_screen.dart';
import 'package:project_ta/screens/detail_ujian_screen.dart';
import 'package:project_ta/screens/detail_video_screen.dart';
import 'package:project_ta/screens/home_screen.dart';
import 'package:project_ta/screens/notifikasi_screen.dart';
import 'package:project_ta/screens/soal_ujian_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';
import 'package:project_ta/screens/video_edukasi_screen.dart';
import 'bloc/WA/WA_bloc.dart';
import 'models/ujian_model.dart';
import 'screens/login_screen.dart';
import 'bloc/auth/auth_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => VideoEdukasiBloc()),
        BlocProvider(create: (context) => NotifikasiBloc()),
        BlocProvider(create: (context) => UjianBloc()),
        BlocProvider(create: (context) => SoalUjianBloc()),
        BlocProvider(create: (context) => CommentsBloc()),
        BlocProvider(create: (context) => HistoryVideoBloc()),
        BlocProvider(create: (context) => HadiahBloc()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => KuponBloc()),
        BlocProvider(create: (context) => HistoryUjianBloc()),
        BlocProvider(create: (context) => HistoryVideoBloc()),
        BlocProvider(create: (context) => UsersBloc()),
        BlocProvider(create: (context) => JawabanSiswaBloc()),
        BlocProvider(create: (context) => MengikutiUjianBloc()),
        BlocProvider(create: (context) => WaBloc()),
        BlocProvider(create: (context) => CloudflareBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edukasiin',
        initialRoute: "/login",
        routes: {
          "/login": (context) => LoginScreen(),
          "/home" : (context) => HomeScreen(),
          "/notifikasi" : (context) => NotifikasiScreen(),
          "/ujian" : (context) => UjianScreen(),
          "/detail-ujian": (context) {
            // Ambil arguments yang dikirim via Navigator
            final ujian = ModalRoute.of(context)!.settings.arguments as UjianModel;
            return DetailUjianScreen(ujian: ujian);
          },
          "/soal-ujian" : (context) {
            final ujian = ModalRoute.of(context)!.settings.arguments as UjianModel;
            return SoalUjianScreen(
              ujian: ujian,
              durationMinutes: ujian.durasi,
            );
          },
          "/video-edukasi": (context) => VideoEdukasiScreen(),
          "/daftar-video" : (context) {
            final mapel = ModalRoute.of(context)!.settings.arguments as String;
            return DaftarVideoEdukasiScreen(
                mapel: mapel
            );
          } ,
          "/daftar-video-guru" : (context) {
            final mapel = ModalRoute.of(context)!.settings.arguments as String;
            return DaftarVideoEdukasiGuruScreen(
                mapel: mapel
            );
          } ,
          "/detail-video" : (context){
            final video = ModalRoute.of(context)!.settings.arguments as VideoEdukasiModel;
            return DetailVideoScreen(
              video: video,
            );
          },
        },
      ),
    );
  }
}

