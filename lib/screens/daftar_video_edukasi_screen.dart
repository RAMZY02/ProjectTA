import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/video_edukasi/video_edukasi_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';
import '../bloc/video_edukasi/video_edukasi_state.dart';
import '../models/video_edukasi_model.dart';

class DaftarVideoEdukasiScreen extends StatefulWidget {
  final String mapel;

  const DaftarVideoEdukasiScreen({super.key, required this.mapel});

  @override
  State<DaftarVideoEdukasiScreen> createState() => _DaftarVideoEdukasiScreenState();
}

class _DaftarVideoEdukasiScreenState extends State<DaftarVideoEdukasiScreen> {
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
    // First filter by subject
    var filtered = videos.where((video) => video.mapel == widget.mapel).toList();

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

  Color getMapelColor() {
    switch (widget.mapel) {
      case 'Pendidikan Agama Islam dan Budi Pekerti':
        return const Color(0xFF4CAF50);
      case 'Pendidikan Agama Hindu dan Budi Pekerti':
        return const Color(0xFF4CAF50);
      case 'Pendidikan Agama Kristen dan Budi Pekerti':
        return const Color(0xFF4CAF50);
      case 'Pendidikan Agama Katolik dan Budi Pekerti':
        return const Color(0xFF4CAF50);
      case 'Pendidikan Pancasila dan Kewarganegaraan':
        return const Color(0xFFF44336); // Merah
      case 'Bahasa Indonesia':
        return const Color(0xFFFF9800); // Orange
      case 'Bahasa Inggris':
        return const Color(0xFF2196F3); // Biru
      case 'Matematika':
        return const Color(0xFF1976D2); // Biru tua
      case 'IPA':
        return const Color(0xFF800080); // Ungu
      case 'IPS':
        return const Color(0xFF795548); // Coklat
      case 'PJOK':
        return const Color(0xFF009688); // Teal
      case 'Seni dan Budaya':
        return const Color(0xFFE91E63); // Pink
      case 'Informatika':
        return const Color(0xFF00BCD4); // Cyan
      default:
        return const Color(0xFFA52A2A); // Coklat tua (default)
    }
  }

  IconData getMapelIcon() {
    switch (widget.mapel) {
      case 'Pendidikan Agama Islam dan Budi Pekerti':
        return Icons.mosque;
      case 'Pendidikan Agama Hindu dan Budi Pekerti':
        return Icons.temple_hindu;
      case 'Pendidikan Agama Kristen dan Budi Pekerti':
        return Icons.church;
      case 'Pendidikan Agama Katolik dan Budi Pekerti':
        return Icons.church;
      case 'Pendidikan Pancasila dan Kewarganegaraan':
        return Icons.flag;
      case 'Bahasa Indonesia':
        return Icons.language;
      case 'Bahasa Inggris':
        return Icons.translate;
      case 'Matematika':
        return Icons.calculate;
      case 'IPA':
        return Icons.science;
      case 'IPS':
        return Icons.public;
      case 'PJOK':
        return Icons.sports;
      case 'Seni dan Budaya':
        return Icons.palette;
      case 'Informatika':
        return Icons.computer;
      default:
        return Icons.menu_book; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapelColor = getMapelColor();
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: widget.mapel.length > 20 ? const Size.fromHeight(210) : const Size.fromHeight(180),
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                              width: 300, // Atur lebar sesuai kebutuhan
                              child: Text(
                                widget.mapel,
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
                          padding: widget.mapel.length > 20 ? EdgeInsets.only(top: 25) : EdgeInsets.zero,
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
                              getMapelIcon(),
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
                Future.microtask(() {
                  context.read<VideoEdukasiBloc>().add(
                    FetchVideos(token: authState.token, userId: authState.id),
                  );
                });
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
                              _searchController.text.isEmpty
                                  ? 'Belum ada video edukasi untuk ${widget.mapel}'
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
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey[500],
                                        size: 28,
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