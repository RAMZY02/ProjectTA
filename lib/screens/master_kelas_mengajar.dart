import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_event.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_kelas_mengajar_screen.dart';

class MasterKelasMengajarScreen extends StatefulWidget {
  const MasterKelasMengajarScreen({super.key});

  @override
  State<MasterKelasMengajarScreen> createState() => _MasterKelasMengajarScreenState();
}

class _MasterKelasMengajarScreenState extends State<MasterKelasMengajarScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter
  String _selectedStatus = 'Semua';
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

  // Fungsi untuk filter kelas mengajar berdasarkan query dan filter
  List<dynamic> _filterKelasMengajar(List<dynamic> kelasMengajarList, String query) {
    List<dynamic> filtered = kelasMengajarList;

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((kelasMengajar) {
        return kelasMengajar.kelas.toLowerCase().contains(query) ||
            kelasMengajar.idUser.toString().contains(query) ||
            kelasMengajar.id.toString().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Fungsi untuk mendapatkan daftar status unik
  List<String> _getStatusList(List<dynamic> kelasMengajarList) {
    Set<String> statusSet = {'Semua'};
    for (var kelasMengajar in kelasMengajarList) {
      statusSet.add(kelasMengajar.keyStatus);
    }
    return statusSet.toList();
  }

  // Fungsi untuk mendapatkan daftar kelas unik
  List<String> _getKelasList(List<dynamic> kelasMengajarList) {
    Set<String> kelasSet = {'Semua'};
    for (var kelasMengajar in kelasMengajarList) {
      kelasSet.add(kelasMengajar.kelas);
    }
    return kelasSet.toList();
  }

  String _getStatusText(String keyStatus) {
    switch (keyStatus) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Nonaktif';
      default:
        return keyStatus;
    }
  }

  Color _getStatusColor(String keyStatus) {
    switch (keyStatus) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Fungsi untuk mendapatkan warna kelas
  Color _getKelasColor(String kelas) {
    // Generate color berdasarkan hash dari string kelas
    int hash = kelas.hashCode;
    return Colors.primaries[hash.abs() % Colors.primaries.length];
  }

  void _deleteKelasMengajar(int id, AuthState state) {
    if(state is Authenticated){
      context.read<KelasMengajarBloc>().add(DeleteKelasMengajar(token: state.token, id: id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kelas mengajar berhasil dihapus')),
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
                              hintText: 'Cari berdasarkan kelas, ID user...',
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
                  label: const Text('Tambah Kelas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsertKelasMengajarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DataTable
            Expanded(
              child: BlocBuilder<KelasMengajarBloc, KelasMengajarState>(
                builder: (context, kelasMengajarState) {
                  if (authState is! Authenticated) {
                    return const Center(child: Text("Silakan login terlebih dahulu"));
                  }
                  if (kelasMengajarState is KelasMengajarInitial) {
                    context.read<KelasMengajarBloc>().add(FetchAllKelasMengajar(token: authState.token));
                  }
                  if (kelasMengajarState is KelasMengajarLoaded) {
                    // Filter kelas mengajar berdasarkan search query dan filter
                    final filteredKelasMengajar = _filterKelasMengajar(
                        kelasMengajarState.kelasMengajarList,
                        _searchQuery,
                    );

                    if (filteredKelasMengajar.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.class_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedStatus == 'Semua' && _selectedKelas == 'Semua'
                                ? "Belum ada data kelas mengajar tersedia"
                                : "Tidak ditemukan kelas mengajar dengan filter yang dipilih",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    // Tampilkan info filter
                    Widget filterInfo = Container();
                    if (_searchQuery.isNotEmpty || _selectedStatus != 'Semua' || _selectedKelas != 'Semua') {
                      filterInfo = Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filteredKelasMengajar.length} dari ${kelasMengajarState.kelasMengajarList.length} kelas mengajar',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _selectedStatus != 'Semua' || _selectedKelas != 'Semua')
                              TextButton.icon(
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Reset Filter'),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedStatus = 'Semua';
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
                                    DataColumn(label: Text('ID Guru')),
                                    DataColumn(label: Text('Kelas')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 100,
                                        child: Center(
                                          child: Text('Aksi'),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: filteredKelasMengajar.map((kelasMengajar) {
                                    final kelasColor = _getKelasColor(kelasMengajar.kelas);

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Center(
                                            child: Text(
                                              kelasMengajar.id.toString(),
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
                                              const Icon(Icons.person,
                                                  size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                kelasMengajar.idUser.toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.class_,
                                                  size: 14, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Kelas ${kelasMengajar.kelas}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              _getStatusText(kelasMengajar.keyStatus),
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
                                                      builder: (context) => InsertKelasMengajarScreen(
                                                        kelasMengajarData: kelasMengajar,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red, size: 20),
                                                onPressed: () => _deleteKelasMengajar(kelasMengajar.id, authState),
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
                  } else if (kelasMengajarState is KelasMengajarError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            kelasMengajarState.message,
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
                                context.read<KelasMengajarBloc>().add(
                                    FetchAllKelasMengajar(token: authState.token)
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