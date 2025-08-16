import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/insert_ujian_screen.dart';
import 'package:project_ta/screens/membuat_soal_screen.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_event.dart';

class SoalScreen extends StatelessWidget {
  const SoalScreen({super.key});

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Bahasa Indonesia')) return Icons.language;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('TIK')) return Icons.computer;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Bahasa Indonesia')) return Colors.red;
    if (title.contains('IPA')) return Colors.purple;
    if (title.contains('Matematika')) return Colors.blue;
    if (title.contains('TIK')) return Colors.brown;
    return Colors.grey; // Default
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
      body: BlocBuilder<UjianBloc, UjianState>(
        builder: (context, ujianState){
          if (authState is Authenticated && ujianState is UjianInitial) {
            Future.microtask(() {
              context.read<UjianBloc>().add(FetchUjian2(token: authState.token));
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembuatSoalScreen(ujian: ujian),
                        ),
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
        }
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