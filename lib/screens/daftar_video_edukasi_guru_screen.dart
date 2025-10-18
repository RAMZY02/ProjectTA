import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/video_edukasi/video_edukasi_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';
import '../bloc/video_edukasi/video_edukasi_state.dart';
import '../models/video_edukasi_model.dart';
import 'insert_video_edukasi_screen.dart';

class DaftarVideoEdukasiGuruScreen extends StatefulWidget {
  const DaftarVideoEdukasiGuruScreen({super.key});

  @override
  State<DaftarVideoEdukasiGuruScreen> createState() => _DaftarVideoEdukasiGuruScreenState();
}

class _DaftarVideoEdukasiGuruScreenState extends State<DaftarVideoEdukasiGuruScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<VideoEdukasiModel> _filteredVideos;
  int _selectedFilterIndex = 0; // 0: Semua, 1: Kelas 7, 2: Kelas 8, 3: Kelas 9
  final List<String> _filterOptions = ['Semua', 'Kelas 7', 'Kelas 8', 'Kelas 9'];

  @override
  void initState() {
    super.initState();
    _filteredVideos = [];
    _searchController.addListener(_filterVideos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVideos() {
    final query = _searchController.text.toLowerCase();
    final videoState = context.read<VideoEdukasiBloc>().state;

    if (videoState is VideoLoaded) {
      setState(() {
        _filteredVideos = _applyFilters(videoState.videos, query);
      });
    }
  }

  List<VideoEdukasiModel> _applyFilters(List<VideoEdukasiModel> videos, String query) {
    final authState = context.read<AuthBloc>().state;
    if(authState is! Authenticated) return [];
    // First filter by subject
    var filtered = videos.where((video) => video.mapel == authState.mapel).toList();

    // Then filter by class if not "Semua"
    if (_selectedFilterIndex > 0) {
      final selectedClass = _filterOptions[_selectedFilterIndex].replaceAll('Kelas ', '');
      filtered = filtered.where((video) => video.kelas == selectedClass).toList();
    }

    // Finally apply search filter
    if (query.isNotEmpty) {
      filtered = filtered.where((video) {
        return video.judul.toLowerCase().contains(query) ||
            video.kelas.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Color getMapelColor(String title) {
    title = title.toLowerCase();

    if (title.contains('islam')) return const Color(0xFF4CAF50); // Hijau
    if (title.contains('hindu')) return const Color(0xFF4CAF50); // Hijau
    if (title.contains('kristen') || title.contains('katolik')) return const Color(0xFF4CAF50); // Hijau
    if (title.contains('pancasila') || title.contains('kewarganegaraan')) return const Color(0xFFF44336); // Merah
    if (title.contains('bahasa indonesia')) return const Color(0xFFFF9800); // Orange
    if (title.contains('bahasa inggris')) return const Color(0xFF2196F3); // Biru
    if (title.contains('matematika')) return const Color(0xFF1976D2); // Biru tua
    if (title.contains('ipa')) return const Color(0xFF800080); // Ungu
    if (title.contains('ips')) return const Color(0xFF795548); // Coklat
    if (title.contains('pjok')) return const Color(0xFF009688); // Teal
    if (title.contains('seni') || title.contains('budaya')) return const Color(0xFFE91E63); // Pink
    if (title.contains('informatika') || title.contains('tik')) return const Color(0xFF00BCD4); // Cyan

    return const Color(0xFFA52A2A); // Coklat tua (default)
  }

  IconData getMapelIcon(String title) {
    title = title.toLowerCase();

    if (title.contains('islam')) return Icons.mosque;
    if (title.contains('hindu')) return Icons.temple_hindu;
    if (title.contains('kristen') || title.contains('katolik')) return Icons.church;
    if (title.contains('pancasila') || title.contains('kewarganegaraan')) return Icons.flag;
    if (title.contains('bahasa indonesia')) return Icons.language;
    if (title.contains('bahasa inggris')) return Icons.translate;
    if (title.contains('matematika')) return Icons.calculate;
    if (title.contains('ipa')) return Icons.science;
    if (title.contains('ips')) return Icons.public;
    if (title.contains('pjok')) return Icons.sports;
    if (title.contains('seni') || title.contains('budaya')) return Icons.palette;
    if (title.contains('informatika') || title.contains('tik')) return Icons.computer;

    return Icons.menu_book; // Default
  }

  void _deleteVideo(VideoEdukasiModel video, BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text('Apakah Anda yakin ingin menghapus video "${video.judul}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<VideoEdukasiBloc>().add(
                    DeleteVideo(
                      token: authState.token,
                      idVideo: video.id,
                      idUser: authState.id,
                    ),
                  );
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if(authState is! Authenticated) return Text('login');
    final mapelColor = getMapelColor(authState.mapel);
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: authState.mapel.length > 20 ? const Size.fromHeight(210) : const Size.fromHeight(180),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mapelColor.withOpacity(0.9),
                mapelColor.withOpacity(0.7),
                mapelColor.withOpacity(0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Cari video edukasi...",
                              hintStyle: TextStyle(fontSize: 15, color: Colors.grey[600]),
                              prefixIcon: Icon(Icons.search, color: mapelColor, size: 22),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(top: 12),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Video Edukasi",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7, // 70% dari lebar layar
                              child: Text(
                                authState.mapel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: authState.mapel.length > 20 ? EdgeInsets.only(top: 25) : EdgeInsets.zero,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              getMapelIcon(authState.mapel),
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertVideoEdukasiScreen(),
            ),
          );
        },
        backgroundColor: mapelColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
            builder: (context, videoState) {
              if (videoState is VideoLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (videoState is VideoError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        videoState.message,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (authState is Authenticated) {
                            context.read<VideoEdukasiBloc>().add(
                              FetchVideos(token: authState.token, userId: authState.id),
                            );
                          }
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (authState is Authenticated && videoState is VideoInitial) {
                context.read<VideoEdukasiBloc>().add(
                  FetchVideos(token: authState.token, userId: authState.id),
                );
              }

              if (videoState is VideoLoaded) {
                _filteredVideos = _applyFilters(videoState.videos, _searchController.text.toLowerCase());

                return Column(
                  children: [
                    // Filter Navbar
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                _filterOptions[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedFilterIndex == index ? Colors.white : Colors.grey[700],
                                ),
                              ),
                              selected: _selectedFilterIndex == index,
                              selectedColor: mapelColor,
                              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilterIndex = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Video List
                    Expanded(
                      child: _filteredVideos.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 70,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchController.text.isEmpty && authState is Authenticated
                                  ? 'Belum ada video edukasi untuk ${authState.mapel}'
                                  : 'Tidak ditemukan hasil untuk "${_searchController.text}"',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Coba gunakan kata kunci lain atau filter berbeda',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = _filteredVideos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/detail-video",
                                    arguments: video,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Thumbnail with play icon overlay
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              video.thumbnail != '-' && video.thumbnail.isNotEmpty
                                                  ? video.thumbnail
                                                  : "https://dummy-url.com", // URL dummy untuk memicu error
                                              height: 140,
                                              width: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  "assets/icons/default-course.png",
                                                  height: 140,
                                                  width: 110,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              video.judul,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: mapelColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    'Kelas ${video.kelas}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: mapelColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Edit and Delete buttons
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => InsertVideoEdukasiScreen(videoData: video),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteVideo(video, context),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(mapelColor),
                    ),
                    const SizedBox(height: 16),
                    const Text('Memuat video...'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}