import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/insert_ujian_screen.dart';
import 'package:project_ta/screens/membuat_soal_screen.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_event.dart';

class SoalScreen extends StatefulWidget {
  const SoalScreen({super.key});

  @override
  State<SoalScreen> createState() => _SoalScreenState();
}

class _SoalScreenState extends State<SoalScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredUjianList = [];
  bool _isSearching = false;

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Islam')) return Icons.mosque;
    if (title.contains('Hindu')) return Icons.temple_hindu;
    if (title.contains('Kristen')) return Icons.church;
    if (title.contains('Katolik')) return Icons.church;
    if (title.contains('Pancasila') || title.contains('Kewarganegaraan')) return Icons.flag;
    if (title.contains('Bahasa Indonesia')) return Icons.language;
    if (title.contains('Bahasa Inggris')) return Icons.translate;
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('IPS')) return Icons.public;
    if (title.contains('PJOK')) return Icons.sports;
    if (title.contains('Seni') || title.contains('Budaya')) return Icons.palette;
    if (title.contains('Informatika') || title.contains('TIK')) return Icons.computer;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Agama')) return Colors.green;
    if (title.contains('Pancasila') || title.contains('Kewarganegaraan')) return Colors.red;
    if (title.contains('Bahasa Indonesia')) return Colors.orange;
    if (title.contains('Bahasa Inggris')) return Colors.blue;
    if (title.contains('Matematika')) return Colors.indigo;
    if (title.contains('IPA')) return Colors.purple;
    if (title.contains('IPS')) return Colors.brown;
    if (title.contains('PJOK')) return Colors.teal;
    if (title.contains('Seni') || title.contains('Budaya')) return Colors.pink;
    if (title.contains('Informatika') || title.contains('TIK')) return Colors.cyan;
    return Colors.grey; // Default
  }

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
      final mapel = ujian.mapel.toLowerCase();
      final searchLower = query.toLowerCase();

      return nama.contains(searchLower) || mapel.contains(searchLower);
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
      appBar: AppBar(
        title: const Text(
          "Daftar Ujian",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
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
                  borderSide: const BorderSide(color: kPrimaryColor),
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

          // List Ujian
          Expanded(
            child: BlocBuilder<UjianBloc, UjianState>(
                builder: (context, ujianState) {
                  if (authState is Authenticated && ujianState is UjianInitial) {
                    context.read<UjianBloc>().add(FetchAllUjianByIdGuru(token: authState.token, id_guru: authState.id));
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

                    return _buildUjianList(_filteredUjianList, authState);
                  }

                  // Tampilkan semua ujian jika tidak searching
                  if (ujianState is UjianLoaded) {
                    final listUjian = ujianState.ujianList;
                    if (listUjian.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada ujian yang tersedia',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildUjianList(listUjian, authState);
                  }
                  else if (ujianState is UjianLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  else if (ujianState is UjianError) {
                    return Center(child: Text(ujianState.message));
                  }
                  else {
                    return const Center(child: Text(""));
                  }
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsertUjianScreen(),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUjianList(List<dynamic> listUjian, AuthState authState) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: listUjian.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ujian = listUjian[index];
        return Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan logo dan informasi ujian
                Row(
                  children: [
                    // Logo Mata Pelajaran
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getSubjectColor(ujian.mapel).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSubjectIcon(ujian.mapel),
                        color: _getSubjectColor(ujian.mapel),
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Konten Ujian
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ujian.nama,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                                fontSize: 14
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(ujian.tanggal),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${formatTimeOfDay(ujian.mulai)} - ${formatTimeOfDay(ujian.selesai)}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                const Divider(height: 1, color: Colors.grey),

                const SizedBox(height: 12),

                // Button actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Detail Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Detail'),
                        onPressed: () {
                          context.read<SoalUjianBloc>().add(InitSoalUjian());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MembuatSoalScreen(ujian: ujian),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Edit Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        onPressed: () {
                          _editUjian(context, ujian);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Delete Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Hapus'),
                        onPressed: () {
                          _deleteUjian(context, ujian, authState);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('d MMMM yyyy').format(date); // Fallback format
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  void _editUjian(BuildContext context, dynamic ujian) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsertUjianScreen(ujianData: ujian, isEdit: true),
      ),
    );
  }

  void _deleteUjian(BuildContext context, dynamic ujian, AuthState authState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus ujian "${ujian.nama}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (authState is Authenticated) {
                  context.read<UjianBloc>().add(
                    DeleteUjian(token: authState.token, id_ujian: ujian.id),
                  );
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ujian "${ujian.nama}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}