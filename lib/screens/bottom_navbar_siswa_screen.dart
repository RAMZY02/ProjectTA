import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/hadiah_screen.dart';
import 'package:project_ta/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:project_ta/screens/profil_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';
import 'package:project_ta/screens/video_edukasi_screen.dart';

import '../bloc/hadiah/hadiah_event.dart';
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
    HadiahScreen(),
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
            activeIcon: Icon(Icons.card_giftcard, color: Colors.blue),
            icon: Icon(Icons.card_giftcard_outlined, color: Colors.grey),
            label: "Hadiah",
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
            context.read<VideoEdukasiBloc>().add(Init());
            context.read<HadiahBloc>().add(Inits());
            context.read<UjianBloc>().add(InitUjian());
            // context.read<UserBloc>().add(Initial());
            _selectedIndex = index;
          });
        }),
    );
  }
}