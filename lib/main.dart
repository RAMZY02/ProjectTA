import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_event.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_bloc.dart';
import 'package:project_ta/bloc/notifikasi/notifikasi_bloc.dart';
import 'package:project_ta/bloc/pengumpulan_tugas/pengumpulan_tugas_bloc.dart';
import 'package:project_ta/bloc/penilaian_tugas/penilaian_tugas_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:project_ta/screens/bottom_navbar_admin_screen.dart';
import 'package:project_ta/screens/bottom_navbar_guru_screen.dart';
import 'package:project_ta/screens/bottom_navbar_siswa_screen.dart';
import 'package:project_ta/screens/daftar_video_edukasi_guru_screen.dart';
import 'package:project_ta/screens/daftar_video_edukasi_screen.dart';
import 'package:project_ta/screens/detail_ujian_screen.dart';
import 'package:project_ta/screens/detail_video_screen.dart';
import 'package:project_ta/screens/home_screen.dart';
import 'package:project_ta/screens/notifikasi_screen.dart';
import 'package:project_ta/screens/soal_ujian_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';
import 'package:project_ta/screens/video_edukasi_screen.dart';
import 'package:project_ta/services/preferences_manager.dart';
import 'bloc/WA/WA_bloc.dart';
import 'bloc/user/user_event.dart';
import 'models/ujian_model.dart';
import 'screens/login_screen.dart';
import 'bloc/auth/auth_bloc.dart';
import 'services/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager.init();

  runApp(MyApp());
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
        BlocProvider(
          create: (context) => SoalUjianBloc(
            openAIService: OpenAIService(
              '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',
              organizationId: 'org-pLQ7wnbEdBf1aGED9N1djByi',
            ),
          ),
        ),
        BlocProvider(create: (context) => CommentsBloc()),
        BlocProvider(create: (context) => HistoryVideoBloc()),
        BlocProvider(create: (context) => HadiahBloc()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => KuponBloc()),
        BlocProvider(create: (context) => HistoryUjianBloc()),
        BlocProvider(create: (context) => UsersBloc()),
        BlocProvider(create: (context) => JawabanSiswaBloc()),
        BlocProvider(create: (context) => WaBloc()),
        BlocProvider(create: (context) => CloudflareBloc()),
        BlocProvider(create: (context) => TugasBloc()),
        BlocProvider(create: (context) => PengumpulanTugasBloc()),
        BlocProvider(create: (context) => PenilaianTugasBloc()),
        BlocProvider(create: (context) => NilaiAkhirSiswaBloc()),
        BlocProvider(create: (context) => KelasMengajarBloc()),
        BlocProvider(create: (context) => HistoryTugasBloc()),
        BlocProvider(create: (context) => MataPelajaranBloc()),
        BlocProvider(create: (context) => TahunPelajaranBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edukasiin',
        home: AppStartupScreen(),
        routes: {
          "/login": (context) => LoginScreen(),
          "/home": (context) => HomeScreen(),
          "/notifikasi": (context) => NotifikasiScreen(),
          "/ujian": (context) => UjianScreen(),
          "/detail-ujian": (context) {
            final ujian = ModalRoute.of(context)!.settings.arguments as UjianModel;
            return DetailUjianScreen(ujian: ujian);
          },
          "/soal-ujian": (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            final ujian = args['ujian'] as UjianModel;
            final melanjutkan = args['melanjutkan'] as bool;

            return SoalUjianScreen(
              ujian: ujian,
              melanjutkan: melanjutkan,
            );
          },
          "/video-edukasi": (context) => VideoEdukasiScreen(),
          "/daftar-video": (context) {
            final mapel = ModalRoute.of(context)!.settings.arguments as String;
            return DaftarVideoEdukasiScreen(mapel: mapel);
          },
          "/daftar-video-guru": (context) => DaftarVideoEdukasiGuruScreen(),
          "/detail-video": (context) {
            final video = ModalRoute.of(context)!.settings.arguments as VideoEdukasiModel;
            return DetailVideoScreen(video: video);
          },
        },
      ),
    );
  }
}

class AppStartupScreen extends StatelessWidget {
  const AppStartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Kembalikan UI berdasarkan auth state
        if (authState is Authenticated) {

          if(authState.role == 'siswa'){
            context.read<UjianBloc>().add(CekUjianBerlangsung(token: authState.token, id_user: authState.id));
          }

          context.read<UserBloc>().add(LoadUser(
            id: authState.id,
            username: authState.username,
            kelas: authState.kelas,
            agama: authState.agama,
            role: authState.role,
            id_mapel: authState.id_mapel,
            mapel: authState.mapel,
            nomor_ortu: authState.nomor_ortu,
            token: authState.token,
            poin: authState.poin,
            profpic: authState.profpic,
            email: authState.email,
          ));

          // Navigasi berdasarkan role
          Widget targetScreen;
          switch (authState.role) {
            case 'admin':
              targetScreen = BottomNavbarAdminScreen();
              break;
            case 'siswa':
              targetScreen = BottomNavbarSiswaScreen();
              break;
            case 'guru':
              targetScreen = BottomNavbarGuruScreen();
              break;
            default:
              targetScreen = BottomNavbarSiswaScreen();
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
            (route) => false,
          );
        }
        else if(authState is AuthError){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
          );
        }
      },
      child: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          // Handle error
          if (snapshot.hasError || !snapshot.hasData) {
            return LoginScreen();
          }

          final userData = snapshot.data as Map<String, dynamic>;

          // Jika user sudah login, trigger auto login event
          if (userData['isLoggedIn'] == true) {
            // Gunakan postFrameCallback untuk memastikan event dipanggil setelah build selesai
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthBloc>().add(LoginEvent(userData['email'], userData['password']),);
            });

            return SplashScreen();
          }

          // Jika user belum login, langsung ke login screen
          return LoginScreen();
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _checkLoginStatus() async {
    final isLoggedIn = await PreferencesManager.getBool('isLoggedIn');

    if (isLoggedIn) {
      return {
        'isLoggedIn': true,
        'email': await PreferencesManager.getString('email'),
        'password': await PreferencesManager.getString('password'),
      };
    }

    return {'isLoggedIn': false};
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Edukasiin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}