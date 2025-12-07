import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_event.dart';
import 'package:project_ta/bloc/hadiah/hadiah_state.dart';
import 'package:project_ta/bloc/kupon/kupon_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/hadiah_model.dart';

import '../bloc/auth/auth_bloc.dart';

class HadiahScreen extends StatefulWidget {
  const HadiahScreen({super.key});

  @override
  State<HadiahScreen> createState() => _HadiahScreenState();
}

class _HadiahScreenState extends State<HadiahScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HadiahModel> _filteredHadiah = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _filterHadiah(List<HadiahModel> hadiahList) {
    if (_searchQuery.isEmpty) {
      _filteredHadiah = List.from(hadiahList);
    } else {
      _filteredHadiah = hadiahList.where((hadiah) {
        final nama = hadiah.nama.toLowerCase();
        final kategori = hadiah.kategori.toLowerCase();
        final poin = hadiah.poin.toString();

        return nama.contains(_searchQuery) ||
            kategori.contains(_searchQuery) ||
            poin.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _tukarHadiah(int hadiahId) {
    final hadiahState = context.read<HadiahBloc>().state;
    final authState = context.read<AuthBloc>().state;
    final userState = context.read<UserBloc>().state;
    late HadiahModel hadiah;

    if(authState is! Authenticated) return;
    if(userState is! UserLoaded) return;
    if(hadiahState is HadiahLoaded) hadiah = _filteredHadiah.firstWhere((h) => h.id == hadiahId);

    if (userState.poin < hadiah.poin) {
      _showAlertDialog(
        'Poin Tidak Cukup',
        'Maaf, poin Anda tidak cukup untuk menukar hadiah ini. Anda membutuhkan ${hadiah.poin} poin.',
      );
      return;
    }

    if (hadiah.stok <= 0) {
      _showAlertDialog(
        'Stok Habis',
        'Maaf, stok hadiah ini sudah habis.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Anda yakin ingin menukar ${hadiah.nama} dengan ${hadiah.poin} poin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if(hadiahState is HadiahLoaded){
                context.read<HadiahBloc>().add(TukarHadiah(token: authState.token, userId: authState.id, hadiahId: hadiahId, hadiah: hadiahState.hadiah));
              }
              int poin = userState.poin - hadiah.poin;
              context.read<UserBloc>().add(UpdatePoin(token: authState.token, poin: poin));
              context.read<KuponBloc>().add(CreateKupon(token: authState.token, hadiah: hadiah, userId: authState.id));
              Navigator.pop(context);
              _showSuccessDialog(hadiah.nama);
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String namaHadiah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penukaran Berhasil'),
        content: Text('Anda berhasil menukar $namaHadiah. Hadiah dapat diambil di ruang guru.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Daftar Hadiah',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize:  18
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
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari hadiah...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.search,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: _clearSearch,
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),

              // Info Poin User
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Poin Anda:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      backgroundColor: Colors.blue[100],
                      label: BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) {
                            if (userState is UserLoaded) {
                              return Text(
                                '${userState.poin} Poin',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              );
                            } else if (userState is UserError) {
                              return Text(
                                'Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else {
                              return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                          }
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // List Hadiah
              Expanded(
                child: BlocBuilder<HadiahBloc, HadiahState>(
                    builder: (context, hadiahState) {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is Authenticated && hadiahState is HadiahInitial) {
                        context.read<HadiahBloc>().add(FetchHadiah(
                          token: authState.token,
                        ));
                      }

                      if (hadiahState is HadiahLoading) {
                        return const Center(
                            child: CircularProgressIndicator()
                        );
                      } else if (hadiahState is HadiahLoaded) {
                        final hadiahList = hadiahState.hadiah;
                        _filterHadiah(hadiahList);

                        if (_filteredHadiah.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isEmpty
                                      ? Icons.card_giftcard
                                      : Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? "Belum ada hadiah"
                                      : "Hadiah tidak ditemukan",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? "Hadiah akan muncul di sini"
                                      : "Coba kata kunci lain",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            if (authState is Authenticated) {
                              context.read<HadiahBloc>().add(FetchHadiah(
                                token: authState.token,
                              ));
                            }
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = constraints.maxWidth;
                              int crossAxisCount = (screenWidth / 200).round();

                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.45,
                                ),
                                padding: const EdgeInsets.all(8),
                                itemCount: _filteredHadiah.length,
                                itemBuilder: (context, index) {
                                  final hadiah = _filteredHadiah[index];
                                  return _buildHadiahCard(hadiah, constraints.maxWidth);
                                },
                              );
                            },
                          ),
                        );
                      } else if (hadiahState is HadiahError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Terjadi Kesalahan",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  hadiahState.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (authState is Authenticated) {
                                    context.read<HadiahBloc>().add(FetchHadiah(
                                      token: authState.token,
                                    ));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Coba Lagi",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                            child: Text("Memuat data...")
                        );
                      }
                    }
                ),
              )
            ],
          ),
        )
    );
  }

  // Widget terpisah untuk card hadiah
  Widget _buildHadiahCard(HadiahModel hadiah, double screenWidth) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Hadiah dengan Badge Stok
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    width: double.infinity,
                    hadiah.link_gambar,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Gambar tidak tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Badge Stok
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hadiah.stok > 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hadiah.stok > 0 ? 'Stok: ${hadiah.stok}' : 'Habis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info Hadiah
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Nama Hadiah
                    Text(
                      hadiah.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Kategori
                    Row(
                      children: [
                        Icon(Icons.category, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hadiah.kategori,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Poin
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 12, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          '${hadiah.poin} Poin',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Tukar
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                  left: 8,
                  right: 8,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hadiah.stok > 0 ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    elevation: 2,
                  ),
                  onPressed: hadiah.stok > 0 ? () => _tukarHadiah(hadiah.id) : null,
                  child: Text(
                    hadiah.stok > 0 ? 'TUKAR' : 'HABIS',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}