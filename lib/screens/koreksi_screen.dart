import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/screens/daftar_siswa_screen.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_event.dart';

class KoreksiScreen extends StatefulWidget {
  const KoreksiScreen({super.key});

  @override
  State<KoreksiScreen> createState() => _KoreksiScreenState();
}

class _KoreksiScreenState extends State<KoreksiScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredUjianList = [];
  bool _isSearching = false;

  // Fungsi untuk memfilter ujian berdasarkan pencarian
  void _filterUjianList(String query, List<dynamic> originalList) {
    if (query.isEmpty) {
      setState(() {
        _filteredUjianList = originalList;
        _isSearching = false;
      });
      return;
    }

    final filtered = originalList.where((ujian) {
      final nama = ujian.nama.toLowerCase();
      final deskripsi = ujian.deskripsi.toLowerCase();
      final tanggal = _formatDate(ujian.tanggal).toLowerCase();
      final kelas = ujian.kelas.toLowerCase();
      final tingkatan = ujian.tingkatan.toLowerCase();
      final searchLower = query.toLowerCase();

      return nama.contains(searchLower) ||
          deskripsi.contains(searchLower) ||
          tanggal.contains(searchLower) ||
          kelas.contains(searchLower) ||
          tingkatan.contains(searchLower);
    }).toList();

    setState(() {
      _filteredUjianList = filtered;
      _isSearching = true;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredUjianList = [];
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft blue-gray background
      appBar: AppBar(
        title: const Text(
          'Koreksi Ujian',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff6849ef),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari ujian...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff6849ef)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                final ujianState = context.read<UjianBloc>().state;
                if (ujianState is UjianLoaded) {
                  _filterUjianList(value, ujianState.ujianList);
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<UjianBloc, UjianState>(
              builder: (context, ujianState) {
                if (authState is Authenticated && ujianState is UjianInitial) {
                  context.read<UjianBloc>().add(FetchKoreksiUjianByIdGuru(token: authState.token, id_guru: authState.id));
                }

                // Tampilkan hasil pencarian jika sedang searching
                if (_isSearching) {
                  if (_filteredUjianList.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada ujian yang ditemukan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildUjianList(_filteredUjianList);
                }

                if (ujianState is UjianLoaded) {
                  return ujianState.ujianList.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Color(0xff6849ef),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada ujian tersedia',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                      : _buildUjianList(ujianState.ujianList);
                } else if (ujianState is UjianLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Color(0xff6849ef)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Memuat data ujian...',
                          style: TextStyle(
                            color: Color(0xff6849ef),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (ujianState is UjianError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ujianState.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (authState is Authenticated) {
                              context.read<UjianBloc>().add(
                                  FetchKoreksiUjianByIdGuru(token: authState.token, id_guru: authState.id));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6849ef),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text(""));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUjianList(List<dynamic> ujianList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ujianList.length,
      itemBuilder: (context, index) {
        final ujian = ujianList[index];
        final progress = ujian.totalSiswa > 0
            ? ujian.diperiksa / ujian.totalSiswa
            : 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DaftarSiswaScreen(ujian: ujian),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        ujian.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2D3748), // Dark gray for better readability
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                    const SizedBox(height: 10),


                    // Informasi ujian
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      _formatDate(ujian.tanggal),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.access_time_outlined,
                      '${formatTimeOfDay(ujian.mulai)} - ${formatTimeOfDay(ujian.selesai)}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.timer_outlined,
                      'Durasi: ${_calculateDuration(ujian.mulai, ujian.selesai)}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.assignment_outlined,
                      'Jumlah Soal: ${ujian.jumlahSoal}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.assignment_outlined,
                      ujian.kelas != '' && ujian.kelas != '-' ?
                      'Kelas: ${ujian.kelas}' : ujian.tingkatan != '' && ujian.tingkatan != '-' ? 'Kelas: ${ujian.tingkatan}' : '',
                    ),

                    // Deskripsi
                    if (ujian.deskripsi.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(
                            height: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Deskripsi:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ujian.deskripsi,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    const Divider(
                      height: 1,
                      color: Color(0xFFE2E8F0),
                    ),

                    // Progress section
                    const SizedBox(height: 16),
                    _buildProgressInfo(ujian.diperiksa, ujian.totalSiswa),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xff6849ef).withOpacity(0.8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan informasi progress koreksi
  Widget _buildProgressInfo(int jumlahDiperiksa, int totalSiswa) {
    final progress = totalSiswa > 0 ? jumlahDiperiksa / totalSiswa : 1;
    final isCompleted = progress == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Koreksi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),

        // Progress bar dengan container yang lebih modern
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                  )
                      : const LinearGradient(
                    colors: [Color(0xff6849ef), Color(0xff8C6BEF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Teks informasi dengan styling yang lebih baik
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terkoreksi: $jumlahDiperiksa/$totalSiswa siswa',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCompleted
                    ? const Color(0xFF4CAF50)
                    : const Color(0xff6849ef),
              ),
            ),
          ],
        ),

        // Status text
        if (isCompleted)
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Selesai Dikoreksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Tambahkan method untuk menghitung durasi
  String _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final totalMinutes = endMinutes - startMinutes;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours jam $minutes menit';
    } else if (hours > 0) {
      return '$hours jam';
    } else {
      return '$minutes menit';
    }
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}