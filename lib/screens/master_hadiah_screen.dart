import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_event.dart';
import 'package:project_ta/bloc/hadiah/hadiah_state.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_hadiah_screen.dart';

class MasterHadiahScreen extends StatefulWidget {
  const MasterHadiahScreen({super.key});

  @override
  State<MasterHadiahScreen> createState() => _MasterHadiahScreenState();
}

class _MasterHadiahScreenState extends State<MasterHadiahScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter kategori
  String _selectedCategory = 'Semua';

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

  // Fungsi untuk filter hadiah berdasarkan query dan kategori
  List<dynamic> _filterHadiah(List<dynamic> hadiahList, String query, String category) {
    List<dynamic> filtered = hadiahList;

    // Filter berdasarkan kategori
    if (category != 'Semua') {
      filtered = filtered.where((hadiah) => hadiah.kategori == category).toList();
    }

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((hadiah) {
        return hadiah.nama.toLowerCase().contains(query) ||
            hadiah.kategori.toLowerCase().contains(query) ||
            hadiah.poin.toString().contains(query) ||
            hadiah.stok.toString().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Fungsi untuk mendapatkan daftar kategori unik
  List<String> _getCategories(List<dynamic> hadiahList) {
    Set<String> categories = {'Semua'};
    for (var hadiah in hadiahList) {
      categories.add(hadiah.kategori);
    }
    return categories.toList();
  }

  void _deleteHadiah(int id, String token) {
    context.read<HadiahBloc>().add(DeleteHadiah(token: token, hadiahId: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hadiah berhasil dihapus')),
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
                            hintText: 'Cari hadiah berdasarkan nama, kategori, poin...',
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
                label: const Text('Tambah Hadiah'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertHadiahScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Kategori
          BlocBuilder<HadiahBloc, HadiahState>(
            builder: (context, hadiahState) {
              if (hadiahState is HadiahLoaded) {
                final categories = _getCategories(hadiahState.hadiah);

                return Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.blue
                                : Colors.grey[700],
                            fontWeight: _selectedCategory == category
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox(height: 40);
            },
          ),
          const SizedBox(height: 16),

          // DataTable
          Expanded(
            child: BlocBuilder<HadiahBloc, HadiahState>(
              builder: (context, hadiahState) {
                if (authState is! Authenticated) {
                  return const Center(child: Text("Silakan login terlebih dahulu"));
                }
                if (hadiahState is HadiahInitial) {
                  context.read<HadiahBloc>().add(FetchHadiah(token: authState.token));
                }
                if (hadiahState is HadiahLoaded) {
                  // Filter hadiah berdasarkan search query dan kategori
                  final filteredHadiah = _filterHadiah(hadiahState.hadiah, _searchQuery, _selectedCategory);

                  if (filteredHadiah.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedCategory == 'Semua'
                              ? "Belum ada data hadiah tersedia"
                              : "Tidak ditemukan hadiah dengan filter yang dipilih",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  // Tampilkan info filter
                  Widget filterInfo = Container();
                  if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua') {
                    filterInfo = Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menampilkan ${filteredHadiah.length} dari ${hadiahState.hadiah.length} hadiah',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua')
                            TextButton.icon(
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Reset Filter'),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedCategory = 'Semua';
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
                                  DataColumn(label: Text('Nama Hadiah')),
                                  DataColumn(label: Text('Poin'), numeric: true),
                                  DataColumn(label: Text('Stok'), numeric: true),
                                  DataColumn(label: Text('Link Gambar')),
                                  DataColumn(label: Text('Kategori')),
                                  DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text('Aksi'),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: filteredHadiah.map((hadiah) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(hadiah.id.toString())),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            hadiah.nama,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            hadiah.poin.toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            hadiah.stok.toString(),
                                            style: TextStyle(
                                              color: hadiah.stok > 0 ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        )
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(
                                            hadiah.link_gambar,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            hadiah.kategori,
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
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        InsertHadiahScreen(
                                                          hadiahData: hadiah,
                                                        ),
                                                  ),
                                                );

                                                if (result != null) {
                                                  // Refresh data
                                                  context.read<HadiahBloc>()
                                                      .add(FetchHadiah(token: authState.token));
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () => _deleteHadiah(
                                                  hadiah.id, authState.token),
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

  // Helper function untuk warna kategori
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Elektronik':
        return Colors.blue;
      case 'Perlengkapan Sekolah':
        return Colors.green;
      case 'Makanan':
        return Colors.orange;
      case 'Minuman':
        return Colors.red;
      case 'Fashion':
        return Colors.purple;
      case 'Hiburan':
        return Colors.pink;
      case 'Lainnya':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}