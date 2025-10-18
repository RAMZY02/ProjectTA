import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/constants/color.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/ujian/ujian_event.dart';
import '../bloc/ujian/ujian_state.dart';
import '../models/ujian_model.dart';

class UjianScreen extends StatelessWidget {
  const UjianScreen({super.key});

  // Fungsi untuk mendapatkan icon berdasarkan mata pelajaran
  IconData _getSubjectIcon(String title) {
    if (title.contains('Islam')) return Icons.mosque;
    if (title.contains('Hindu')) return Icons.temple_hindu;
    if (title.contains('Kristen')) return Icons.church;
    if (title.contains('Katolik')) return Icons.church;
    if (title.contains('Pancasila') || title.contains('Kewarganegaraan')) return Icons.flag;
    if (title.contains('Bahasa Indonesia')) return Icons.language;
    if (title.contains('Bahasa Inggris')) return Icons.translate;
    if (title.contains('Matematika')) return Icons.calculate;
    if (title.contains('IPA')) return Icons.science;
    if (title.contains('IPS')) return Icons.public;
    if (title.contains('PJOK')) return Icons.sports;
    if (title.contains('Seni') || title.contains('Budaya')) return Icons.palette;
    if (title.contains('Informatika') || title.contains('TIK')) return Icons.computer;
    return Icons.menu_book; // Default
  }

  // Fungsi untuk mendapatkan warna icon
  Color _getSubjectColor(String title) {
    if (title.contains('Agama')) return Colors.green;
    if (title.contains('Pancasila') || title.contains('Kewarganegaraan')) return Colors.red;
    if (title.contains('Bahasa Indonesia')) return Colors.orange;
    if (title.contains('Bahasa Inggris')) return Colors.blue;
    if (title.contains('Matematika')) return Colors.indigo;
    if (title.contains('IPA')) return Colors.purple;
    if (title.contains('IPS')) return Colors.brown;
    if (title.contains('PJOK')) return Colors.teal;
    if (title.contains('Seni') || title.contains('Budaya')) return Colors.pink;
    if (title.contains('Informatika') || title.contains('TIK')) return Colors.cyan;
    return Colors.grey; // Default
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
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
      body: BlocBuilder<UjianBloc, UjianState>(
        builder: (context, ujianState) {
          if (authState is Authenticated && ujianState is UjianInitial) {
            Future.microtask(() {
              context.read<UjianBloc>().add(FetchUjian(token: authState.token, userId: authState.id, kelas: authState.kelas));
            });
          }
          // Handle loading state
          if (ujianState is UjianLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (ujianState is UjianError) {
            return Center(child: Text(ujianState.message));
          }

          // Handle loaded state
          if (ujianState is UjianLoaded) {
            final listUjian = ujianState.ujianList;

            if (listUjian.isEmpty) {
              return const Center(child: Text('Belum ada ujian yang tersedia'));
            }

            return _buildUjianList(context, listUjian, authState);
          }

          // Initial state
          return const Center(child: Text("Memuat data ujian..."));
        },
      )
    );
  }

  Widget _buildUjianList(BuildContext context, List<UjianModel> listUjian, AuthState authState) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: listUjian.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ujian = listUjian[index];
        return _buildUjianItem(context, ujian);
      },
    );
  }

  Widget _buildUjianItem(BuildContext context, UjianModel ujian) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: ujian.isDone ? Colors.grey.shade300 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!ujian.isDone) {
            Navigator.pushNamed(
              context,
              '/detail-ujian',
              arguments: ujian,
            );
          }
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
                        fontSize: 14,
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