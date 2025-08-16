import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/WA/WA_bloc.dart';
import 'package:project_ta/bloc/WA/WA_event.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/bottom_navbar_siswa_screen.dart';

import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/ujian/ujian_event.dart';
import '../constants/color.dart';

class HasilUjianScreen extends StatelessWidget {
  final double pilihanGandaScore;
  final int pilihanGandaCorrect;
  final int pilihanGandaWrong;
  final int pilihanGandaTotal;
  final UjianModel ujian;

  const HasilUjianScreen({
    super.key,
    required this.pilihanGandaScore,
    required this.pilihanGandaCorrect,
    required this.pilihanGandaWrong,
    required this.pilihanGandaTotal,
    required this.ujian,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if(authState is Authenticated){
      final pesan =  'Nilai ${ujian.tipe_ujian} Mata Pelajaran ${ujian.mapel} anak Anda yang bernama ${authState.username} adalah $pilihanGandaScore';
      context.read<WaBloc>().add(SendMessage(pesan: pesan, tujuan: authState.nomor_ortu, token: authState.token));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ujian', style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card for automatically graded multiple-choice questions
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Hasil Pilihan Ganda',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pilihanGandaScore.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreIndicator('Benar', pilihanGandaCorrect, Colors.green),
                        _buildScoreIndicator('Salah', pilihanGandaWrong, Colors.red),
                        _buildScoreIndicator(
                          'Tidak Dijawab',
                          pilihanGandaTotal - pilihanGandaCorrect - pilihanGandaWrong,
                          Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: pilihanGandaScore / 100,
                      backgroundColor: Colors.grey[300],
                      color: _getScoreColor(pilihanGandaScore),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getScoreMessage(pilihanGandaScore),
                      style: TextStyle(
                        color: _getScoreColor(pilihanGandaScore),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<UjianBloc>().add(InitUjian());
                  SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavbarSiswaScreen(initialIndex: 1),
                    ),
                  );
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage(double score) {
    if (score >= 80) return 'Sangat Baik!';
    if (score >= 60) return 'Baik';
    if (score >= 40) return 'Cukup';
    return 'Perlu Belajar Lagi';
  }
}