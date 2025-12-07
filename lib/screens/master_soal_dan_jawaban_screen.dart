import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/insert_soal_dan_jawaban_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/soal_ujian/soal_ujian_state.dart';

class MasterSoalDanJawabanScreen extends StatefulWidget {
  final UjianModel ujian;

  const MasterSoalDanJawabanScreen({
    super.key,
    required this.ujian,
  });

  @override
  State<MasterSoalDanJawabanScreen> createState() => _MasterSoalDanJawabanScreenState();
}

class _MasterSoalDanJawabanScreenState extends State<MasterSoalDanJawabanScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter tipe soal
  String _selectedTipe = 'Semua';

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

  // Fungsi untuk filter soal berdasarkan query dan tipe
  List<dynamic> _filterSoal(List<dynamic> soalList, String query) {
    List<dynamic> filtered = soalList;

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((soal) {
        return soal.soal.toLowerCase().contains(query) ||
            soal.pembahasan.toLowerCase().contains(query) ||
            soal.jawaban.toLowerCase().contains(query) ||
            soal.tipe.toLowerCase().contains(query) ||
            soal.opsiA.toLowerCase().contains(query) ||
            soal.opsiB.toLowerCase().contains(query) ||
            soal.opsiC.toLowerCase().contains(query) ||
            soal.opsiD.toLowerCase().contains(query) ||
            soal.opsiE.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _deleteSoal(int id, int idUjian, String token) {
    context.read<SoalUjianBloc>().add(DeleteSoal(token: token, id: id, id_ujian: idUjian));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Soal berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Soal - ${widget.ujian.nama}'),
      ),
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
                              hintText: 'Cari soal berdasarkan pertanyaan, jawaban, pembahasan...',
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
                  label: const Text('Tambah Soal'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InsertSoalDanJawabanScreen(
                          idUjian: widget.ujian.id,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DataTable
            Expanded(
              child: BlocBuilder<SoalUjianBloc, SoalUjianState>(
                builder: (context, soalUjianState) {
                  if (authState is! Authenticated) {
                    return const Center(child: Text("Silakan login terlebih dahulu"));
                  }
                  if (soalUjianState is SoalUjianInitial) {
                    context.read<SoalUjianBloc>().add(FetchSoalUjian2(token: authState.token, ujianId: widget.ujian.id));
                  }
                  if (soalUjianState is SoalUjianLoaded) {
                    // Filter soal berdasarkan search query dan tipe
                    final filteredSoal = _filterSoal(soalUjianState.soalList, _searchQuery);

                    if (filteredSoal.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.quiz, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty && _selectedTipe == 'Semua'
                                ? "Belum ada soal tersedia untuk ujian ini"
                                : "Tidak ditemukan soal dengan filter yang dipilih",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    // Tampilkan info filter
                    Widget filterInfo = Container();
                    if (_searchQuery.isNotEmpty || _selectedTipe != 'Semua') {
                      filterInfo = Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filteredSoal.length} dari ${soalUjianState.soalList.length} soal',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _selectedTipe != 'Semua')
                              TextButton.icon(
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Reset Filter'),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedTipe = 'Semua';
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
                                    DataColumn(label: Text('Tipe')),
                                    DataColumn(label: Text('Soal')),
                                    DataColumn(label: Text('Opsi A')),
                                    DataColumn(label: Text('Opsi B')),
                                    DataColumn(label: Text('Opsi C')),
                                    DataColumn(label: Text('Opsi D')),
                                    DataColumn(label: Text('Opsi E')),
                                    DataColumn(label: Text('Jawaban')),
                                    DataColumn(label: Text('Pembahasan')),
                                    DataColumn(label: Text('Link Video')),
                                    DataColumn(label: Text('Link Gambar')),
                                    DataColumn(label: Text('Link Audio')),
                                    DataColumn(label: Text('Link Video Pembahasan')),
                                    DataColumn(label: Text('Link Gambar Pembahasan')),
                                    DataColumn(label: Text('Link Audio Pembahasan')),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 100,
                                        child: Center(
                                          child: Text('Actions'),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: filteredSoal.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final soal = entry.value;
                                    final isCorrectAnswer = soal.tipe == 'Pilihan Ganda';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(soal.id.toString())),
                                        DataCell(Text(soal.tipe)),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 200),
                                            child: Text(
                                              soal.soal,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                        ),
                                        // Show "-" for options if not Pilihan Ganda
                                        DataCell(Text(soal.tipe == 'Pilihan Ganda' ? (soal.opsiA.length > 20 ? '${soal.opsiA.substring(0, 20)}...' : soal.opsiA) : '-')),
                                        DataCell(Text(soal.tipe == 'Pilihan Ganda' ? (soal.opsiB.length > 20 ? '${soal.opsiB.substring(0, 20)}...' : soal.opsiB) : '-')),
                                        DataCell(Text(soal.tipe == 'Pilihan Ganda' ? (soal.opsiC.length > 20 ? '${soal.opsiC.substring(0, 20)}...' : soal.opsiC) : '-')),
                                        DataCell(Text(soal.tipe == 'Pilihan Ganda' ? (soal.opsiD.length > 20 ? '${soal.opsiD.substring(0, 20)}...' : soal.opsiD) : '-')),
                                        DataCell(Text(soal.tipe == 'Pilihan Ganda' ? (soal.opsiE.length > 20 ? '${soal.opsiE.substring(0, 20)}...' : soal.opsiE) : '-')),
                                        DataCell(Text(soal.jawaban)),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 200),
                                            child: Text(
                                              soal.pembahasan,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              soal.linkVideo != '-' ? soal.linkVideo : '-',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              soal.linkGambar != '-' ? soal.linkGambar : '-',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              soal.linkAudio != '-' ? soal.linkAudio : '-',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              soal.linkVideoPembahasan != '-' ? soal.linkVideoPembahasan : '-',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              soal.linkGambarPembahasan != '-' ? soal.linkGambarPembahasan : '-',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 150),
                                            child: Text(
                                              soal.linkAudioPembahasan != '-' ? soal.linkAudioPembahasan : '-',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue),
                                                onPressed: () async {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => InsertSoalDanJawabanScreen(
                                                        soalData: soal,
                                                        isEdit: true,
                                                      ),
                                                    ),
                                                  );

                                                  if (result != null) {
                                                    setState(() {
                                                      final index = soalUjianState.soalList.indexWhere((s) => s.id == soal.id);
                                                      if (index != -1) {
                                                        soalUjianState.soalList[index] = result;
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _deleteSoal(soal.id, widget.ujian.id, authState.token),
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
                  } else if (soalUjianState is SoalUjianNotFound) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada soal tersedia",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Soal Pertama'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InsertSoalDanJawabanScreen(
                                  idUjian: widget.ujian.id,
                                ),
                              ),
                            );
                          },
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
      ),
    );
  }

  // Fungsi untuk menampilkan dialog pembahasan
  void _showPembahasanDialog(dynamic soal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pembahasan Soal'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  soal.pembahasan,
                  style: const TextStyle(fontSize: 14),
                ),
                if (soal.linkVideoPembahasan != '-') ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Video Pembahasan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    soal.linkVideoPembahasan,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
                if (soal.linkGambarPembahasan != '-') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Gambar Pembahasan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    soal.linkGambarPembahasan,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
                if (soal.linkAudioPembahasan != '-') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Audio Pembahasan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    soal.linkAudioPembahasan,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}