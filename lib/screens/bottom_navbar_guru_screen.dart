import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:project_ta/screens/koreksi_screen.dart';
import 'package:project_ta/screens/rapot_guru_screen.dart';
import 'package:project_ta/screens/soal_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/screens/video_edukasi_guru_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/history_ujian/history_ujian_event.dart';
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
    VideoEdukasiGuruScreen(),
    RapotGuruScreen(),
    KoreksiScreen(),
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
          child: _selectedIndex == 4
              ? Container() // Kosongkan karena logout akan diproses
              : _widgetOptions.elementAt(_selectedIndex),
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
              label: "Soal",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.video_library, color: Colors.blue),
              icon: Icon(Icons.video_library_outlined, color: Colors.grey),
              label: "Video Edukasi",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.assignment, color: Colors.blue),  // Lebih cocok untuk "Rapot"
              icon: Icon(Icons.assignment_outlined, color: Colors.grey),
              label: "Rapot",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.rate_review, color: Colors.blue),  // Lebih cocok untuk "Koreksi"
              icon: Icon(Icons.rate_review_outlined, color: Colors.grey),
              label: "Koreksi",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.exit_to_app, color: Colors.blue),
              icon: Icon(Icons.exit_to_app_outlined, color: Colors.grey),
              label: "Logout",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if (index == 4) {
              // Jika menekan tombol logout
              context.read<AuthBloc>().add(LogoutEvent());
              context.read<UjianBloc>().add(InitUjian());
              context.read<HistoryUjianBloc>().add(InitialHistoryUjian());
            } else {
              setState(() {
                context.read<UjianBloc>().add(InitUjian());
                context.read<HistoryUjianBloc>().add(InitialHistoryUjian());
                _selectedIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}
