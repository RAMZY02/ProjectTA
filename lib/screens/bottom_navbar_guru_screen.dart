import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_bloc.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_event.dart';
import 'package:project_ta/bloc/nilai_akhir_siswa/nilai_akhir_siswa_state.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:project_ta/screens/daftar_video_edukasi_guru_screen.dart';
import 'package:project_ta/screens/koreksi_screen.dart';
import 'package:project_ta/screens/laporan_nilai_screen.dart';
import 'package:project_ta/screens/profil_guru_screen.dart';
import 'package:project_ta/screens/rapot_wali_kelas_screen.dart';
import 'package:project_ta/screens/soal_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/screens/tugas_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/history_ujian/history_ujian_event.dart';
import '../bloc/tugas/tugas_bloc.dart';
import '../bloc/tugas/tugas_event.dart';
import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/ujian/ujian_event.dart';
import 'login_screen.dart';

class BottomNavbarGuruScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavbarGuruScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavbarGuruScreen> createState() => _BottomNavbarGuruScreenState();
}

class _BottomNavbarGuruScreenState extends State<BottomNavbarGuruScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    SoalScreen(),
    DaftarVideoEdukasiGuruScreen(),
    TugasScreen(),
    KoreksiScreen(),
    ProfilGuruScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthInitial) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryColor,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          selectedLabelStyle: TextStyle(height: 1.5),
          unselectedLabelStyle: TextStyle(height: 1.5),
          items: [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.quiz, color: Colors.blue),  // Lebih cocok untuk "Soal"
              icon: Icon(Icons.quiz_outlined, color: Colors.grey),
              label: "Ujian",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.video_library, color: Colors.blue),
              icon: Icon(Icons.video_library_outlined, color: Colors.grey),
              label: "Video Edukasi",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.assignment, color: Colors.blue),
              icon: Icon(Icons.assignment_outlined, color: Colors.grey),
              label: "Tugas",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.rate_review, color: Colors.blue),  // Lebih cocok untuk "Koreksi"
              icon: Icon(Icons.rate_review_outlined, color: Colors.grey),
              label: "Koreksi",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.person, color: Colors.blue),
              icon: Icon(Icons.person_outline, color: Colors.grey),
              label: "Profil",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              if(index == 0){
                context.read<UjianBloc>().add(InitUjian());
              }
              else if(index == 1){
                context.read<VideoEdukasiBloc>().add(InitVideoEdukasi());
              }
              else if(index == 2){
                context.read<TugasBloc>().add(TugasInit());
              }
              else if(index == 3){
                context.read<UjianBloc>().add(InitUjian());
                context.read<HistoryUjianBloc>().add(InitialHistoryUjian());
              }
              else{
                context.read<NilaiAkhirSiswaBloc>().add(InitNilaiAkhirSiswa());
                context.read<HistoryUjianBloc>().add(InitialHistoryUjian());
              }
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
