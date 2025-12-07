import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_state.dart';
import 'package:project_ta/screens/insert_video_edukasi_admin_screen.dart';
import '../bloc/auth/auth_state.dart';

class MasterVideoEdukasiScreen extends StatefulWidget {
  const MasterVideoEdukasiScreen({super.key});

  @override
  State<MasterVideoEdukasiScreen> createState() => _MasterVideoEdukasiScreenState();
}

class _MasterVideoEdukasiScreenState extends State<MasterVideoEdukasiScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter
  String _selectedMapel = 'Semua';
  String _selectedKelas = 'Semua';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk filter video berdasarkan query dan filter
  List<dynamic> _filterVideos(List<dynamic> videosList, String query, String mapel, String kelas) {
    List<dynamic> filtered = videosList;

    // Filter berdasarkan mata pelajaran
    if (mapel != 'Semua') {
      filtered = filtered.where((video) => video.mapel == mapel).toList();
    }

    // Filter berdasarkan kelas
    if (kelas != 'Semua') {
      filtered = filtered.where((video) => video.kelas == kelas).toList();
    }

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((video) {
        return video.judul.toLowerCase().contains(query) ||
            video.mapel.toLowerCase().contains(query) ||
            video.deskripsi.toLowerCase().contains(query) ||
            video.views.toString().contains(query) ||
            video.likes.toString().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Fungsi untuk mendapatkan daftar mata pelajaran unik
  List<String> _getMapelList(List<dynamic> videosList) {
    Set<String> mapelSet = {'Semua'};
    for (var video in videosList) {
      mapelSet.add(video.mapel);
    }
    return mapelSet.toList();
  }

  // Fungsi untuk mendapatkan daftar kelas unik
  List<String> _getKelasList(List<dynamic> videosList) {
    Set<String> kelasSet = {'Semua'};
    for (var video in videosList) {
      kelasSet.add(video.kelas);
    }
    return kelasSet.toList();
  }

  void _deleteVideo(int id, AuthState state) {
    if(state is Authenticated){
      context.read<VideoEdukasiBloc>().add(DeleteVideo(token: state.token, idVideo: id, idUser: state.id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row untuk Search Bar dan Add Button
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari video berdasarkan judul, mata pelajaran, deskripsi...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Video'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InsertVideoEdukasiAdminScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Row (Mata Pelajaran dan Kelas)
            BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
              builder: (context, videoState) {
                if (videoState is VideoLoaded) {
                  final mapelList = _getMapelList(videoState.videos);
                  final kelasList = _getKelasList(videoState.videos);

                  return Column(
                    children: [
                      // Filter Mata Pelajaran
                      Container(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mapelList.length,
                          itemBuilder: (context, index) {
                            final mapel = mapelList[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(mapel),
                                selected: _selectedMapel == mapel,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedMapel = mapel;
                                  });
                                },
                                selectedColor: Colors.blue[100],
                                checkmarkColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: _selectedMapel == mapel
                                      ? Colors.blue
                                      : Colors.grey[700],
                                  fontWeight: _selectedMapel == mapel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }
                return const SizedBox(height: 48);
              },
            ),
            const SizedBox(height: 16),

            // DataTable
            Expanded(
              child: BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
                builder: (context, videoState) {
                  if (authState is! Authenticated) {
                    return const Center(child: Text("Silakan login terlebih dahulu"));
                  }
                  if (videoState is VideoInitial) {
                    context.read<VideoEdukasiBloc>().add(FetchVideos(token: authState.token, userId: authState.id));
                  }
                  if (videoState is VideoLoaded) {
                    // Filter video berdasarkan search query dan filter
                    final filteredVideos = _filterVideos(
                        videoState.videos,
                        _searchQuery,
                        _selectedMapel,
                        _selectedKelas
                    );

                    if (filteredVideos.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_library, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedMapel == 'Semua' && _selectedKelas == 'Semua'
                                ? "Belum ada data video tersedia"
                                : "Tidak ditemukan video dengan filter yang dipilih",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    // Tampilkan info filter
                    Widget filterInfo = Container();
                    if (_searchQuery.isNotEmpty || _selectedMapel != 'Semua' || _selectedKelas != 'Semua') {
                      filterInfo = Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filteredVideos.length} dari ${videoState.videos.length} video',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Reset Filter'),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedMapel = 'Semua';
                                  _selectedKelas = 'Semua';
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        filterInfo,
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 20,
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('Judul')),
                                    DataColumn(label: Text('Mata Pelajaran')),
                                    DataColumn(label: Text('Kelas')),
                                    DataColumn(label: Text('Views'), numeric: true),
                                    DataColumn(label: Text('Likes'), numeric: true),
                                    DataColumn(label: Text('Thumbnail')),
                                    DataColumn(label: Text('Deskripsi')),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 100,
                                        child: Center(
                                          child: Text('Aksi'),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: filteredVideos.map((video) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(video.id.toString())),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 200),
                                            child: Text(
                                              video.judul,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            video.mapel,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            'Kelas ${video.kelas}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.visibility,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  video.views.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.thumb_up,
                                                    size: 14, color: Colors.pink),
                                                const SizedBox(width: 4),
                                                Text(
                                                  video.likes.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.pink[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            width: 100,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: video.thumbnail != null &&
                                                  video.thumbnail.isNotEmpty &&
                                                  video.thumbnail != '-'
                                                  ? DecorationImage(
                                                image: NetworkImage(video.thumbnail),
                                                fit: BoxFit.cover,
                                              )
                                                  : const DecorationImage(
                                                image: AssetImage('assets/video_placeholder.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 200),
                                            child: Text(
                                              video.deskripsi,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue, size: 20),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          InsertVideoEdukasiAdminScreen(
                                                            videoData: video,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red, size: 20),
                                                onPressed: () => _deleteVideo(video.id, authState),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}