import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/soal_ujian_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/soal_ujian/soal_ujian_bloc.dart';
import '../bloc/soal_ujian/soal_ujian_event.dart';

class DetailUjianScreen extends StatelessWidget {
  final UjianModel ujian;

  const DetailUjianScreen({super.key, required this.ujian});

  @override
  Widget build(BuildContext context) {

    // 1. Dapatkan token dari state auth
    final token = context.select<AuthBloc, String>((authBloc) {
      if (authBloc.state is Authenticated) {
        return (authBloc.state as Authenticated).token;
      }
      return '';
    });

    // 2. Trigger fetch soal ujian
    context.read<SoalUjianBloc>().add(
      FetchSoalUjian(
        token: token,
        ujianId: ujian.id, // Pastikan Anda memiliki akses ke object ujian
      ),
    );

    return Scaffold(
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
                          _buildDetailRow(Icons.calendar_today, 'Tanggal', ujian.tanggal.toString()),
                          _buildDetailRow(Icons.access_time, 'Waktu', '${ujian.mulai} - ${ujian.selesai}'),
                          _buildDetailRow(Icons.timer, 'Durasi', ujian.durasi.toString()),
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
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                ],
              ),
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
              onPressed: () {
                // 3. Navigasi ke halaman soal
                Navigator.pushNamed(
                  context,
                  '/soal-ujian',
                  arguments: ujian,
                );
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
}