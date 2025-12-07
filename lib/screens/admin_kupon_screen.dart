import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/kupon/kupon_state.dart';

import '../bloc/auth/auth_state.dart';
import '../constants/color.dart';

class AdminKuponScreen extends StatefulWidget {
  const AdminKuponScreen({super.key});

  @override
  State<AdminKuponScreen> createState() => _AdminKuponScreenState();
}

class _AdminKuponScreenState extends State<AdminKuponScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahkan variabel untuk filter status
  String _selectedStatus = 'Semua';

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

  // Fungsi untuk filter kupon berdasarkan query dan status
  List<dynamic> _filterKupons(List<dynamic> kuponList, String query, String status) {
    List<dynamic> filtered = kuponList;

    // Filter berdasarkan status
    if (status != 'Semua') {
      filtered = filtered.where((kupon) => kupon.status == status).toList();
    }

    // Filter berdasarkan query pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((kupon) {
        return kupon.hadiah.nama.toLowerCase().contains(query) ||
            kupon.kode.toLowerCase().contains(query) ||
            kupon.id.toString().contains(query) ||
            (kupon.namaUser != null && kupon.namaUser.toLowerCase().contains(query)) ||
            (kupon.userId != null && kupon.userId.toString().contains(query)) ||
            (kupon.idUser != null && kupon.idUser.toString().contains(query));
      }).toList();
    }

    return filtered;
  }

  // Fungsi untuk mendapatkan daftar status unik
  List<String> _getStatusList(List<dynamic> kuponList) {
    Set<String> statusSet = {'Semua'};
    for (var kupon in kuponList) {
      statusSet.add(kupon.status);
    }
    return statusSet.toList();
  }

  // Fungsi untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'claimed':
        return Colors.green;
      case 'available':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      case 'used':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Fungsi untuk mendapatkan teks status
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'claimed':
        return 'Telah Diklaim';
      case 'available':
        return 'Tersedia';
      case 'expired':
        return 'Kadaluarsa';
      case 'used':
        return 'Digunakan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Kupon",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
            padding: const EdgeInsets.all(16),
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
                        hintText: 'Cari kupon berdasarkan kode, hadiah...',
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

          // Filter Status
          BlocBuilder<KuponBloc, KuponState>(
            builder: (context, kuponState) {
              if (kuponState is KuponLoaded) {
                final statusList = _getStatusList(kuponState.kupons);

                return Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusList.length,
                    itemBuilder: (context, index) {
                      final status = statusList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            status == 'Semua' ? 'Semua Status' : _getStatusText(status),
                          ),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                          selectedColor: _getStatusColor(status),
                          backgroundColor: Colors.grey[100],
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedStatus == status
                                ? Colors.white
                                : _getStatusColor(status),
                            fontWeight: _selectedStatus == status
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox(height: 50);
            },
          ),

          // List Kupon
          Expanded(
            child: BlocBuilder<KuponBloc, KuponState>(
              builder: (context, kuponState) {
                if (authState is! Authenticated) {
                  return const Center(
                    child: Text(
                      "Silakan login terlebih dahulu",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                if (kuponState is! KuponLoaded || kuponState.kupons.isEmpty) {
                  if (kuponState is KuponInitial) {
                    Future.microtask(() {
                      context.read<KuponBloc>().add(FetchAllKupon(token: authState.token));
                    });
                  }

                  // Tampilkan loading atau empty state
                  if (kuponState is KuponLoaded && kuponState.kupons.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.confirmation_number_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada kupon tersedia",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                }

                // Filter kupon berdasarkan search query dan status
                final filteredKupons = _filterKupons(
                    kuponState.kupons,
                    _searchQuery,
                    _selectedStatus
                );

                if (filteredKupons.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty && _selectedStatus == 'Semua'
                            ? "Belum ada kupon tersedia"
                            : "Tidak ditemukan kupon dengan filter yang dipilih",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                // Tampilkan info filter
                Widget filterInfo = Container();
                if (_searchQuery.isNotEmpty || _selectedStatus != 'Semua') {
                  filterInfo = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menampilkan ${filteredKupons.length} dari ${kuponState.kupons.length} kupon',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || _selectedStatus != 'Semua')
                          TextButton.icon(
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Reset Filter'),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedStatus = 'Semua';
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
                      child: ListView.builder(
                        itemCount: filteredKupons.length,
                        itemBuilder: (context, index) {
                          final kupon = filteredKupons[index];
                          final statusColor = _getStatusColor(kupon.status);
                          final statusText = _getStatusText(kupon.status);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header dengan ID dan Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'ID: ${kupon.id}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          border: Border.all(color: statusColor),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Kode Kupon
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Center(
                                      child: Text(
                                        kupon.kode,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Informasi Hadiah
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.card_giftcard,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kupon.hadiah.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${kupon.hadiah.poin} Poin',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk format tanggal
  String _formatDate(DateTime date) {
    try {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    } catch (e) {
      return date.toString();
    }
  }
}