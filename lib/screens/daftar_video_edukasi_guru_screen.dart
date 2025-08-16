import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/video_edukasi/video_edukasi_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';
import '../bloc/video_edukasi/video_edukasi_state.dart';
import '../models/video_edukasi_model.dart';
import '../constants/color.dart';
import 'insert_video_edukasi_screen.dart';

class DaftarVideoEdukasiGuruScreen extends StatefulWidget {
  final String mapel;

  const DaftarVideoEdukasiGuruScreen({super.key, required this.mapel});

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
    // First filter by subject
    var filtered = videos.where((video) => video.mata_pelajaran == widget.mapel).toList();

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
      case 'Matematika':
        return const Color(0xFF1976D2);
      case 'IPA':
        return const Color(0xFF800080);
      case 'Bahasa Indonesia':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFA52A2A);
    }
  }

  IconData getMapelIcon() {
    switch (widget.mapel) {
      case 'Matematika':
        return Icons.calculate;
      case 'IPA':
        return Icons.science;
      case 'Bahasa Indonesia':
        return Icons.language;
      default:
        return Icons.computer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapelColor = getMapelColor();

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mapelColor.withOpacity(0.9),
                  mapelColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 4, right: 16, bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.78,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Cari Video...",
                            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                            suffixIcon: Icon(Icons.search, color: kPrimaryColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 16, top: 5),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.only(left: 32, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.mapel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              getMapelIcon(),
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
                builder: (context, videoState) {
                  if (videoState is VideoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (videoState is VideoError) {
                    return Center(child: Text(videoState.message));
                  }

                  if (authState is Authenticated && videoState is VideoInitial) {
                    Future.microtask(() {
                      context.read<VideoEdukasiBloc>().add(FetchVideos(token: authState.token, userId: authState.id));
                    });
                  }

                  if (videoState is VideoLoaded) {
                    _filteredVideos = _applyFilters(videoState.videos, _searchController.text.toLowerCase());

                    return Column(
                      children: [
                        // Filter Navbar
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filterOptions.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: ChoiceChip(
                                  label: Text(_filterOptions[index]),
                                  selected: _selectedFilterIndex == index,
                                  selectedColor: mapelColor,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedFilterIndex == index ? Colors.white : Colors.black,
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
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'Tidak ada video edukasi untuk mata pelajaran ini'
                                      : 'Tidak ditemukan hasil untuk "${_searchController.text}"',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filteredVideos.length,
                            itemBuilder: (context, index) {
                              final video = _filteredVideos[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context,
                                      "/detail-video",
                                      arguments: video
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          'https://picsum.photos/850/650?random=4',
                                          width: 120,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              video.judul,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Kelas ${video.kelas}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Icon(
                                          Icons.play_circle_filled,
                                          color: mapelColor,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text("Tidak ada data"));
                },
              );
            }
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
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}