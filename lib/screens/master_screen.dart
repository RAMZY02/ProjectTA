import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/screens/master_comments_screen.dart';
import 'package:project_ta/screens/master_hadiah_screen.dart';
import 'package:project_ta/screens/master_mata_pelajaran_screen.dart';
import 'package:project_ta/screens/master_ujian_screen.dart';
import 'package:project_ta/screens/master_video_edukasi_screen.dart';

import '../bloc/comments/comments_event.dart';
import '../bloc/hadiah/hadiah_event.dart';
import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/users/users_event.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';
import 'master_user_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<MasterMenuItem> _menuItems = [
    MasterMenuItem(title: 'User', screen: const MasterUserScreen()),
    MasterMenuItem(title: 'Ujian', screen: const MasterUJianScreen()),
    MasterMenuItem(title: 'Hadiah', screen: const MasterHadiahScreen()),
    MasterMenuItem(title: 'Video Edukasi', screen: const MasterVideoEdukasiScreen()),
    MasterMenuItem(title: 'Comments', screen: const MasterCommentsScreen()),
    MasterMenuItem(title: 'Mata Pelajaran', screen: const MasterMataPelajaranScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
      body: Column(
        children: [
          // Navbar
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _menuItems.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: _selectedIndex == index ? Colors.blue : Colors.grey,
                    backgroundColor: _selectedIndex == index ? Colors.blue.withOpacity(0.1) : null,
                  ),
                  onPressed: () => _onNavItemTapped(index),
                  child: Text(_menuItems[index].title),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              children: _menuItems.map((item) => item.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        context.read<UsersBloc>().add(Init());
        break;
      case 1:
        context.read<UjianBloc>().add(InitUjian());
        break;
      case 2:
        context.read<HadiahBloc>().add(Inits());
        break;
      case 3:
        context.read<VideoEdukasiBloc>().add(InitVideoEdukasi());
        break;
      case 4:
        context.read<CommentsBloc>().add(InitComment());
        break;
    }
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}

class MasterMenuItem {
  final String title;
  final Widget screen;

  MasterMenuItem({
    required this.title,
    required this.screen,
  });
}