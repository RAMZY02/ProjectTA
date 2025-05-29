import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ta/screens/bottom_navbar_siswa_screen.dart';

import '../constants/color.dart';
import '../widgets/segemented_progressbar.dart';

class HasilUjianScreen extends StatelessWidget {
  final double pilihanGandaScore;
  final int pilihanGandaCorrect;
  final int pilihanGandaWrong;
  final int pilihanGandaTotal;
  final int isianTotal;
  final int uploadFileTotal;

  const HasilUjianScreen({
    super.key,
    required this.pilihanGandaScore,
    required this.pilihanGandaCorrect,
    required this.pilihanGandaWrong,
    required this.pilihanGandaTotal,
    required this.isianTotal,
    required this.uploadFileTotal,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = pilihanGandaTotal + isianTotal + uploadFileTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ujian', style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
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
                      '${pilihanGandaScore.toStringAsFixed(2)}',
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

            // Card for manually graded questions
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jawaban yang Perlu Penilaian Guru',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (isianTotal > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '$isianTotal Soal Isian',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Jawaban Anda akan diperiksa oleh guru terlebih dahulu',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (uploadFileTotal > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.upload_file, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text(
                                '$uploadFileTotal Soal Upload File',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'File Anda akan diperiksa oleh guru terlebih dahulu',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Distribution of question types
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribusi Soal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    SegmentedProgressBar(
                      segments: {
                        'Pilihan Ganda': pilihanGandaTotal.toDouble(),
                        'Isian': isianTotal.toDouble(),
                        'Upload File': uploadFileTotal.toDouble(),
                      },
                      height: 24,
                      showPercentage: true,
                    ),

                    const SizedBox(height: 16),

                    // Tambahan informasi jumlah soal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCountInfo('Pilihan Ganda', pilihanGandaTotal, Colors.blue),
                        _buildCountInfo('Isian', isianTotal, Colors.orange),
                        _buildCountInfo('Upload', uploadFileTotal, Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: () {
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

  Widget _buildCountInfo(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
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

  Widget _buildProgressRow(String label, double percentage, Color color, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(info),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 8,
        ),
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