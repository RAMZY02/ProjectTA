import 'package:project_ta/constants/color.dart';
import 'package:project_ta/constants/icons.dart';
import 'package:project_ta/constants/size.dart';
import 'package:project_ta/screens/hadiah_screen.dart';
import 'package:project_ta/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:project_ta/screens/profil_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';
import 'package:project_ta/screens/videoEdukasi_screen.dart';

import 'login_screen.dart';

class BottomNavbarScreen extends StatefulWidget {
  final int initialIndex; // Tambahkan parameter ini

  const BottomNavbarScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbarScreen> {
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
              _selectedIndex = index;
            });
          }),
    );
  }
}