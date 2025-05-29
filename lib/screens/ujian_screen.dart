import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/detail_ujian_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/ujian/ujian_event.dart';
import '../bloc/ujian/ujian_state.dart';

class UjianScreen extends StatelessWidget {
  const UjianScreen({super.key});

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('Bahasa')) return Icons.language;
    if (title.contains('Sejarah')) return Icons.history;
    if (title.contains('IPS')) return Icons.public;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Matematika')) return Colors.blue;
    if (title.contains('IPA')) return Colors.green;
    if (title.contains('Bahasa')) return Colors.purple;
    if (title.contains('Sejarah')) return Colors.orange;
    if (title.contains('IPS')) return Colors.brown;
    return Colors.grey; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ini yang menghilangkan tombol back
        title: const Text(
          "Daftar Ujian",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,// Custom shadow color
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<UjianBloc, UjianState>(
            builder: (context, ujianState) {
              // Fetch ujian data if authenticated and data not loaded
              if (authState is Authenticated &&
                  (ujianState is! UjianLoaded || ujianState.ujianList.isEmpty)) {
                Future.microtask(() {
                  context.read<UjianBloc>().add(FetchUjian(token: authState.token));
                });
              }

              if (ujianState is UjianLoaded) {
                final listUjian = ujianState.ujianList;
                if (listUjian.isEmpty) {
                  return const Center(
                    child: Text('Belum ada ujian yang tersedia'),
                  );
                }
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Di UjianScreen atau tempat lain ketika ingin navigate:
                          Navigator.pushNamed(
                            context,
                            '/detail-ujian',
                            arguments: ujian, // Ini object UjianModel yang akan dikirim
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
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
                                          ujian.tanggal.toString(),
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
                                          '${ujian.mulai} - ${ujian.selesai}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
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
            },
          );
        },
      ),
    );
  }
}