
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/ujian_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/history_ujian/history_ujian_bloc.dart';
import '../bloc/history_ujian/history_ujian_event.dart';
import '../bloc/soal_ujian/soal_ujian_bloc.dart';
import '../bloc/soal_ujian/soal_ujian_event.dart';

class DetailUjianScreen extends StatelessWidget {
  final UjianModel ujian;

  const DetailUjianScreen({super.key, required this.ujian});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: []
    );

    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          "Detail Ujian",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: double.infinity, // Ini yang membuat lebar sama
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                ujian.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            const Divider(height: 24, thickness: 1),
                            _buildDetailRow(Icons.calendar_today, 'Tanggal', _formatDate(ujian.tanggal)),
                            _buildDetailRow(Icons.access_time, 'Waktu', '${formatTimeOfDay(ujian.mulai)} - ${formatTimeOfDay(ujian.selesai)}'),
                            _buildDetailRow(Icons.timer, 'Durasi', _calculateDuration(ujian.mulai, ujian.selesai)),
                            _buildDetailRow(Icons.person, 'Pengajar', ujian.guru),
                            _buildDetailRow(Icons.format_list_numbered, 'Jumlah Soal', '${ujian.jumlahSoal} soal'),
                            const SizedBox(height: 16),
                            const Text(
                              'Deskripsi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ujian.deskripsi,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: double.infinity, // Sama dengan Card pertama
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Petunjuk Ujian:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('1. Baca soal dengan teliti', style: TextStyle(fontSize: 14)),
                            Text('2. Waktu ujian tidak dapat dihentikan', style: TextStyle(fontSize: 14)),
                            Text('3. Jawaban tidak dapat diubah setelah dikirim', style: TextStyle(fontSize: 14)),
                            Text('4. Dilarang bekerja sama dengan peserta lain', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async{
                // 1. Cek apakah user sudah terautentikasi
                if (authState is! Authenticated) {
                  return; // atau tampilkan snackbar error
                }

                // 2. Dapatkan waktu dan tanggal sekarang
                final now = DateTime.now();
                final currentDate = DateTime(now.year, now.month, now.day);
                final currentTime = TimeOfDay.fromDateTime(now);

                // 3. Parse tanggal dan waktu ujian
                final ujianDate = ujian.tanggal; // Asumsi ini adalah DateTime
                final ujianTime = ujian.mulai;   // Asumsi ini adalah TimeOfDay

                // 4. Bandingkan tanggal dan waktu
                final isSameDate = currentDate.year == ujianDate.year &&
                    currentDate.month == ujianDate.month &&
                    currentDate.day == ujianDate.day;

                final isTimeValid = currentTime.hour > ujianTime.hour ||
                    (currentTime.hour == ujianTime.hour &&
                        currentTime.minute >= ujianTime.minute);

                // 5. Logika pengecekan
                if (!isSameDate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ujian belum dimulai, tanggal ujian: ${_formatDate(ujian.tanggal)}')),
                  );
                } else if (!isTimeValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ujian belum dimulai, waktu ujian: ${ujian.mulai.format(context)}')),
                  );
                } else {

                    context.read<HistoryUjianBloc>().add(CreateHistoryUjian(token: authState.token, userId: authState.id, ujianId: ujian.id, nilai: 0));
                    context.read<SoalUjianBloc>().add(InitSoalUjian());
                    Navigator.pushNamed(
                      context,
                      '/soal-ujian',
                      arguments: {
                        'ujian': ujian,
                        'melanjutkan': false,
                      },
                    );

                }
              },
              child: const Text(
                'MULAI UJIAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tambahkan method untuk menghitung durasi
  String _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final totalMinutes = endMinutes - startMinutes;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours jam $minutes menit';
    } else if (hours > 0) {
      return '$hours jam';
    } else {
      return '$minutes menit';
    }
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