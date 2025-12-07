import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_event.dart';
import 'package:project_ta/bloc/tugas/tugas_state.dart';
import 'package:project_ta/models/tugas_model.dart';
import 'package:project_ta/screens/insert_tugas_admin_screen.dart';

import '../bloc/auth/auth_state.dart';

class MasterTugasScreen extends StatefulWidget {
  const MasterTugasScreen({super.key});

  @override
  State<MasterTugasScreen> createState() => _MasterTugasScreenState();
}

class _MasterTugasScreenState extends State<MasterTugasScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter kelas
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

  // Fungsi untuk filter tugas berdasarkan query dan kelas
  List<TugasModel> _filterTugas(List<TugasModel> tugasList, String query, String kelas) {
    List<TugasModel> filtered = tugasList;

    // Filter berdasarkan kelas
    if (kelas != 'Semua') {
      filtered = filtered.where((tugas) => tugas.kelas == kelas).toList();
    }

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((tugas) {
        return tugas.nama.toLowerCase().contains(query) ||
            tugas.deskripsi.toLowerCase().contains(query) ||
            tugas.kelas.toLowerCase().contains(query) ||
            tugas.id.toString().contains(query) ||
            tugas.user!.nama.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Fungsi untuk mendapatkan daftar kelas unik
  List<String> _getKelasList(List<TugasModel> tugasList) {
    Set<String> kelasSet = {'Semua'};
    for (var tugas in tugasList) {
      kelasSet.add(tugas.kelas);
    }
    return kelasSet.toList();
  }

  // Fungsi untuk mendapatkan warna kelas
  Color _getKelasColor(String kelas) {
    // Generate color berdasarkan hash dari string kelas
    int hash = kelas.hashCode;
    return Colors.primaries[hash.abs() % Colors.primaries.length];
  }

  void _deleteTugas(String token, int id) {
    context.read<TugasBloc>().add(DeleteTugas(token: token, tugasId: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Padding(
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
                            hintText: 'Cari tugas berdasarkan nama, deskripsi, kelas, guru...',
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
                label: const Text('Tambah Tugas'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertTugasAdminScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // DataTable
          Expanded(
            child: BlocBuilder<TugasBloc, TugasState>(
              builder: (context, tugasState) {
                if (authState is! Authenticated) {
                  return const Center(child: Text("Silakan login terlebih dahulu"));
                }
                if (tugasState is TugasInitial) {
                  context.read<TugasBloc>().add(FetchTugas(token: authState.token));
                }
                if (tugasState is TugasLoaded) {
                  // Filter tugas berdasarkan search query dan kelas
                  final filteredTugas = _filterTugas(tugasState.tugas, _searchQuery, _selectedKelas);

                  if (filteredTugas.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedKelas == 'Semua'
                              ? "Belum ada data tugas tersedia"
                              : "Tidak ditemukan tugas dengan filter yang dipilih",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  // Tampilkan info filter
                  Widget filterInfo = Container();
                  if (_searchQuery.isNotEmpty || _selectedKelas != 'Semua') {
                    filterInfo = Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menampilkan ${filteredTugas.length} dari ${tugasState.tugas.length} tugas',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedKelas != 'Semua')
                            TextButton.icon(
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Reset Filter'),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
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
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Nama')),
                                  DataColumn(label: Text('Guru')),
                                  DataColumn(label: Text('Kelas')),
                                  DataColumn(label: Text('Deskripsi')),
                                  DataColumn(label: Text('Deadline')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Actions'),
                                      ),
                                    ),
                                  )
                                ],
                                rows: filteredTugas.map((tugas) {
                                  final kelasColor = _getKelasColor(tugas.kelas);
                                  final isDeadlineNear = _isDeadlineNear(tugas.deadline);

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            tugas.id.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            tugas.nama,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            tugas.user?.nama ?? 'Tidak diketahui',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            'Kelas ${tugas.kelas}',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(
                                            tugas.deskripsi,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            _formatDate(tugas.deadline),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
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
                                                        InsertTugasAdminScreen(
                                                          tugasData: tugas,
                                                          guruData: tugas.user,
                                                          isEdit: true,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () =>
                                                  _deleteTugas(authState.token, tugas.id),
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
                } else if (tugasState is TugasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          tugasState.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengecek apakah deadline sudah dekat
  bool _isDeadlineNear(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays <= 3 && difference.inDays >= 0;
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('d MMM yyyy').format(date); // Fallback format
    }
  }
}