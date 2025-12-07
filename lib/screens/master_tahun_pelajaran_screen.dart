import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_state.dart';
import 'insert_tahun_pelajaran_screen.dart';

class MasterTahunPelajaranScreen extends StatefulWidget {
  const MasterTahunPelajaranScreen({super.key});

  @override
  State<MasterTahunPelajaranScreen> createState() => _MasterTahunPelajaranScreenState();
}

class _MasterTahunPelajaranScreenState extends State<MasterTahunPelajaranScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter semester
  String _selectedSemester = 'Semua';

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

  // Fungsi untuk filter tahun pelajaran berdasarkan query dan semester
  List<dynamic> _filterTahunPelajaran(List<dynamic> tahunPelajaranList, String query) {
    List<dynamic> filtered = tahunPelajaranList;

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((tahunPelajaran) {
        return tahunPelajaran.tahun.toLowerCase().contains(query) ||
            tahunPelajaran.semester.toLowerCase().contains(query) ||
            tahunPelajaran.id.toString().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _deleteTahunPelajaran(int id, AuthState state) {
    if(state is Authenticated){
      context.read<TahunPelajaranBloc>().add(DeleteTahunPelajaran(token: state.token, id: id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahun pelajaran berhasil dihapus')),
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
                              hintText: 'Cari tahun pelajaran berdasarkan nama tahun, semester...',
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
                  label: const Text('Tambah Tahun'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsertTahunPelajaranScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DataTable
            Expanded(
              child: BlocBuilder<TahunPelajaranBloc, TahunPelajaranState>(
                builder: (context, tahunPelajaranState) {
                  if (authState is! Authenticated) {
                    return const Center(child: Text("Silakan login terlebih dahulu"));
                  }
                  if (tahunPelajaranState is TahunPelajaranInitial) {
                    context.read<TahunPelajaranBloc>().add(FetchAllTahunPelajaran(token: authState.token));
                  }
                  if (tahunPelajaranState is TahunPelajaranLoaded) {
                    // Filter tahun pelajaran berdasarkan search query dan semester
                    final filteredTahunPelajaran = _filterTahunPelajaran(
                        tahunPelajaranState.tahunPelajaranList,
                        _searchQuery,
                    );

                    if (filteredTahunPelajaran.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedSemester == 'Semua'
                                ? "Belum ada data tahun pelajaran tersedia"
                                : "Tidak ditemukan tahun pelajaran dengan filter yang dipilih",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    // Tampilkan info filter
                    Widget filterInfo = Container();
                    if (_searchQuery.isNotEmpty || _selectedSemester != 'Semua') {
                      filterInfo = Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filteredTahunPelajaran.length} dari ${tahunPelajaranState.tahunPelajaranList.length} tahun pelajaran',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _selectedSemester != 'Semua')
                              TextButton.icon(
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Reset Filter'),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedSemester = 'Semua';
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
                                    DataColumn(label: Text('Tahun Pelajaran')),
                                    DataColumn(label: Text('Semester')),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 100,
                                        child: Center(
                                          child: Text('Aksi'),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: filteredTahunPelajaran.map((tahunPelajaran) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Center(
                                            child: Text(
                                              tahunPelajaran.id.toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 14, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text(
                                                tahunPelajaran.tahun,
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              tahunPelajaran.semester,
                                              style: const TextStyle(
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
                                                      builder: (context) => InsertTahunPelajaranScreen(
                                                        tahunPelajaranData: tahunPelajaran,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red, size: 20),
                                                onPressed: () => _deleteTahunPelajaran(tahunPelajaran.id, authState),
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
                  } else if (tahunPelajaranState is TahunPelajaranError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            tahunPelajaranState.message,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            onPressed: () {
                              if (authState is Authenticated) {
                                context.read<TahunPelajaranBloc>().add(
                                    FetchAllTahunPelajaran(token: authState.token)
                                );
                              }
                            },
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
      ),
    );
  }
}