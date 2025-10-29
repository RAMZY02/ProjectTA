import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_event.dart';
import 'package:project_ta/bloc/history_video/history_video_state.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_event.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/hadiah_screen.dart';
import 'package:project_ta/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:project_ta/screens/profil_screen.dart';
import 'package:project_ta/screens/tugas_siswa_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';
import 'package:project_ta/screens/video_edukasi_screen.dart';

import '../bloc/hadiah/hadiah_event.dart';
import '../bloc/history_ujian/history_ujian_event.dart';
import '../bloc/video_edukasi/video_edukasi_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';

class BottomNavbarSiswaScreen extends StatefulWidget {
  final int initialIndex; // Tambahkan parameter ini

  const BottomNavbarSiswaScreen({super.key, this.initialIndex = 0});

  @override
  _BottomNavbarSiswaState createState() => _BottomNavbarSiswaState();
}

class _BottomNavbarSiswaState extends State<BottomNavbarSiswaScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Gunakan initialIndex saat inisialisasi
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    UjianScreen(),
    VideoEdukasiScreen(),
    TugasSiswaScreen(),
    ProfilScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            activeIcon: Icon(Icons.home, color: Colors.blue),
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            label: "Home",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.quiz, color: Colors.blue), // atau Icons.assignment
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
            activeIcon: Icon(Icons.person, color: Colors.blue),
            icon: Icon(Icons.person_outline, color: Colors.grey),
            label: "Profil",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            if(index == 0){
              context.read<VideoEdukasiBloc>().add(InitVideoEdukasi());
            }
            else if(index == 1){
              context.read<UjianBloc>().add(InitUjian());
            }
            else if(index == 2){
              context.read<VideoEdukasiBloc>().add(InitVideoEdukasi());
              context.read<MataPelajaranBloc>().add(InitialMataPelajaran());
            }
            else if(index == 3){
              context.read<TugasBloc>().add(TugasInit());
            }
            else if(index == 4){
              context.read<KuponBloc>().add(InitialKupon());
              context.read<MataPelajaranBloc>().add(InitialMataPelajaran());
              context.read<HistoryUjianBloc>().add(InitialHistoryUjian());
              context.read<HistoryVideoBloc>().add(InitialHistoryVideo());
              context.read<HadiahBloc>().add(Inits());
            }
            _selectedIndex = index;
          });
        }),
    );
  }
}