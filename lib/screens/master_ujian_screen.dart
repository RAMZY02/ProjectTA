import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/insert_ujian_admin_screen.dart';
import 'package:project_ta/screens/master_soal_dan_jawaban_screen.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/soal_ujian/soal_ujian_event.dart';

class MasterUJianScreen extends StatefulWidget {
  const MasterUJianScreen({super.key});

  @override
  State<MasterUJianScreen> createState() => _MasterUJianScreenState();
}

class _MasterUJianScreenState extends State<MasterUJianScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  // Fungsi untuk filter ujian berdasarkan query
  List<UjianModel> _filterUjian(List<UjianModel> ujianList, String query) {
    if (query.isEmpty) return ujianList;

    return ujianList.where((ujian) {
      return ujian.nama.toLowerCase().contains(query) ||
          ujian.mapel.toLowerCase().contains(query) ||
          ujian.kelas.toLowerCase().contains(query) ||
          ujian.tingkatan.toLowerCase().contains(query) ||
          ujian.tipe_ujian.toLowerCase().contains(query) ||
          ujian.tipe_soal.toLowerCase().contains(query) ||
          ujian.guru.toLowerCase().contains(query) ||
          ujian.kode.toLowerCase().contains(query) ||
          _formatDate(ujian.tanggal).toLowerCase().contains(query);
    }).toList();
  }

  void _deleteUjian(String token, int id) {
    context.read<UjianBloc>().add(DeleteUjian(token: token, id_ujian: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ujian deleted successfully')),
    );
  }

  Future<void> _navigateToSoalScreen(UjianModel ujian) async {
    context.read<SoalUjianBloc>().add(InitSoalUjian());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasterSoalDanJawabanScreen(ujian: ujian),
      ),
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
                            hintText: 'Cari ujian berdasarkan nama, mata pelajaran, kelas, guru...',
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
                label: const Text('Tambah Ujian'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertUjianAdminScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: BlocBuilder<UjianBloc, UjianState>(
              builder: (context, ujianState) {
                if (authState is! Authenticated) {
                  return const Center(child: Text("Silakan login terlebih dahulu"));
                }
                if (ujianState is UjianInitial) {
                  Future.microtask(() {
                    context
                        .read<UjianBloc>()
                        .add(FetchUjian2(token: authState.token));
                  });
                }
                if (ujianState is UjianLoaded) {
                  // Filter ujian berdasarkan search query
                  final filteredUjian = _filterUjian(ujianState.ujianList, _searchQuery);

                  if (filteredUjian.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? "Belum ada data ujian tersedia"
                              : "Tidak ditemukan ujian dengan kata kunci '$_searchQuery'",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  // Tampilkan jumlah hasil pencarian
                  Widget searchInfo = Container();
                  if (_searchQuery.isNotEmpty) {
                    searchInfo = Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Menampilkan ${filteredUjian.length} dari ${ujianState.ujianList.length} ujian',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      searchInfo,
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              // Enable mouse drag
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical, // Scroll vertikal
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal, // Scroll horizontal
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Nama')),
                                  DataColumn(label: Text('Mata Pelajaran')),
                                  DataColumn(label: Text('Tingkatan')),
                                  DataColumn(label: Text('Kelas')),
                                  DataColumn(label: Text('Tipe Ujian')),
                                  DataColumn(label: Text('Tipe Soal')),
                                  DataColumn(label: Text('Tanggal')),
                                  DataColumn(label: Text('Mulai')),
                                  DataColumn(label: Text('Selesai')),
                                  DataColumn(label: Text('Jumlah Soal')),
                                  DataColumn(label: Text('Deskripsi')),
                                  DataColumn(label: Text('Kode')),
                                  DataColumn(label: Text('Guru')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Actions'),
                                      ),
                                    ),
                                  )
                                ],
                                rows: filteredUjian.map((ujian) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(ujian.id.toString())),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            ujian.nama,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            ujian.mapel,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Center(child: Text(ujian.tingkatan))),
                                      DataCell(Center(child: Text(ujian.kelas))),
                                      DataCell(Text(ujian.tipe_ujian)),
                                      DataCell(Text(ujian.tipe_soal)),
                                      DataCell(
                                        Text(_formatDate(ujian.tanggal).toString()),
                                      ),
                                      DataCell(Center(
                                          child: Text(
                                              formatTimeOfDay(ujian.mulai).toString()))),
                                      DataCell(Center(
                                          child: Text(
                                              formatTimeOfDay(ujian.selesai).toString()))),
                                      DataCell(Center(
                                          child: Text(ujian.jumlahSoal.toString()))),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            ujian.deskripsi,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(ujian.kode)),
                                      DataCell(Text(ujian.guru)),
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
                                                        InsertUjianAdminScreen(
                                                          ujianData: ujian,
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
                                                  _deleteUjian(authState.token, ujian.id),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.assignment,
                                                  color: Colors.green, size: 20),
                                              onPressed: () =>
                                                  _navigateToSoalScreen(ujian),
                                              tooltip: 'Kelola Soal',
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
    // Format jam dan menit dengan leading zero
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute'; // Format 10.00
  }
}