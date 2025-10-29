import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:project_ta/bloc/pengumpulan_tugas/pengumpulan_tugas_bloc.dart';
import 'package:project_ta/bloc/penilaian_tugas/penilaian_tugas_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/user/user_event.dart';
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
import 'package:project_ta/screens/soal_ujian_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';
import 'package:project_ta/screens/video_edukasi_screen.dart';
import 'package:project_ta/services/notification_service.dart';
import 'package:project_ta/services/preferences_manager.dart';
import 'package:project_ta/bloc/WA/WA_bloc.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/login_screen.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/services/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesManager.init();

  // Inisialisasi notifications dengan error handling (hanya untuk mobile)
  if (!kIsWeb) {
    try {
      await NotificationService.initialize();
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

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
        home: PermissionWrapper(),
        routes: {
          "/login": (context) => LoginScreen(),
          "/home": (context) => HomeScreen(),
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

class PermissionWrapper extends StatefulWidget {
  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _isCheckingPermissions = true;
  bool _showPermissionDialog = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    // Untuk web, langsung skip permission dialog
    if (kIsWeb) {
      setState(() {
        _isCheckingPermissions = false;
        _showPermissionDialog = false;
      });
      return;
    }

    final prefs = await PreferencesManager.getInstance();
    final bool isFirstTime = prefs.getBool('permissions_requested') ?? true;

    if (isFirstTime) {
      // Untuk pertama kali, selalu tampilkan dialog permission
      setState(() {
        _isCheckingPermissions = false;
        _showPermissionDialog = true;
      });
    } else {
      // Untuk subsequent launches, cek jika ada permission yang ditolak
      final deniedPermissions = await _getDeniedPermissions();

      setState(() {
        _isCheckingPermissions = false;
        _showPermissionDialog = deniedPermissions.isNotEmpty;
      });
    }
  }

  Future<List<Permission>> _getDeniedPermissions() async {
    // Untuk web, return empty list karena tidak perlu permission
    if (kIsWeb) {
      return [];
    }

    final List<Permission> requiredPermissions = [
      Permission.photos,
      Permission.videos,
      Permission.notification,
      Permission.camera,
      Permission.microphone,
    ];

    List<Permission> deniedPermissions = [];

    for (var permission in requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        deniedPermissions.add(permission);
      }
    }

    return deniedPermissions;
  }

  void _onPermissionsGranted() async {
    final prefs = await PreferencesManager.getInstance();
    await prefs.setBool('permissions_requested', false);

    setState(() {
      _showPermissionDialog = false;
    });
  }

  void _onSkipPermissions() async {
    final prefs = await PreferencesManager.getInstance();
    await prefs.setBool('permissions_requested', false);

    setState(() {
      _showPermissionDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return SplashScreen();
    }

    if (_showPermissionDialog) {
      return PermissionDialog(
        onAllPermissionsGranted: _onPermissionsGranted,
        onSkip: _onSkipPermissions,
      );
    }

    return AppStartupScreen();
  }
}

class PermissionDialog extends StatefulWidget {
  final Function() onAllPermissionsGranted;
  final Function() onSkip;

  const PermissionDialog({
    super.key,
    required this.onAllPermissionsGranted,
    required this.onSkip,
  });

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = true;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Untuk web, langsung skip karena tidak perlu permission
    if (kIsWeb) {
      setState(() {
        _isLoading = false;
      });
      widget.onSkip();
      return;
    }

    setState(() => _isLoading = true);

    final List<Permission> requiredPermissions = [
      Permission.photos, // Untuk gambar/foto
      Permission.videos, // Untuk video
      Permission.notification,
      Permission.camera,
      Permission.microphone,
    ];

    Map<Permission, PermissionStatus> statuses = {};
    for (var permission in requiredPermissions) {
      statuses[permission] = await permission.status;
    }

    setState(() {
      _permissionStatuses = statuses;
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    // Untuk web, langsung skip karena tidak perlu permission
    if (kIsWeb) {
      widget.onAllPermissionsGranted();
      return;
    }

    setState(() => _isRequesting = true);

    Map<Permission, PermissionStatus> results = {};
    for (var permission in _permissionStatuses.keys) {
      results[permission] = await permission.request();
    }

    setState(() {
      _permissionStatuses = results;
      _isRequesting = false;
    });

    // Cek jika semua permission sudah diberikan
    final allGranted = _permissionStatuses.values.every((status) => status.isGranted);
    if (allGranted) {
      widget.onAllPermissionsGranted();
    }
  }

  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.photos:
        return 'Mengakses foto dan gambar';
      case Permission.videos:
        return 'Mengakses video';
      case Permission.notification:
        return 'Mengirim notifikasi';
      case Permission.camera:
        return 'Mengakses kamera';
      case Permission.microphone:
        return 'Mengakses mikrofon';
      default:
        return 'Fitur aplikasi';
    }
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.photos:
        return Icons.photo_library;
      case Permission.videos:
        return Icons.video_library;
      case Permission.notification:
        return Icons.notifications;
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.microphone:
        return Icons.mic;
      default:
        return Icons.settings;
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Diizinkan';
      case PermissionStatus.denied:
        return 'Ditolak';
      case PermissionStatus.permanentlyDenied:
        return 'Diblokir';
      default:
        return 'Tidak diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Untuk web, tampilkan dialog khusus web atau langsung skip
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.language,
                  size: 60,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  'Aplikasi Web Edukasiin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Anda menggunakan versi web. Untuk pengalaman terbaik, gunakan aplikasi mobile.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: widget.onSkip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: Text(
                    'LANJUTKAN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.security,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Izin yang Diperlukan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aplikasi membutuhkan izin berikut untuk berfungsi dengan baik:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView(
                    children: _permissionStatuses.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getPermissionIcon(entry.key),
                              color: Colors.blue,
                              size: 30,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getPermissionDescription(entry.key),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getStatusText(entry.value),
                                    style: TextStyle(
                                      color: _getStatusColor(entry.value),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onSkip,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue),
                      ),
                      child: Text(
                        'NANTI',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isRequesting
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'IZINKAN SEMUA',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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