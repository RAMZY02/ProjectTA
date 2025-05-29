import 'package:flutter/material.dart';
import 'package:project_ta/screens/master_comments_screen.dart';
import 'package:project_ta/screens/master_hadiah_screen.dart';
import 'package:project_ta/screens/master_ujian_screen.dart';
import 'package:project_ta/screens/master_video_edukasi_screen.dart';

import 'master_soal_dan_jawaban_screen.dart';
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
    MasterMenuItem(title: 'Soal & Jawaban', screen: const MasterUJianScreen()),
    MasterMenuItem(title: 'Hadiah', screen: const MasterHadiahScreen()),
    MasterMenuItem(title: 'Video Edukasi', screen: const MasterVideoEdukasiScreen()),
    MasterMenuItem(title: 'Comments', screen: const MasterCommentsScreen()),
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