import 'package:flutter/material.dart';
import 'package:project_ta/screens/bottomNavbar_screen.dart';
import 'package:project_ta/screens/ujian_screen.dart';

class HasilUjianScreen extends StatelessWidget {
  final double score;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;

  const HasilUjianScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ujian'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Nilai Anda',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${score.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildScoreIndicator(
                            'Benar',
                            correctAnswers,
                            Colors.green
                        ),
                        _buildScoreIndicator(
                            'Salah',
                            wrongAnswers,
                            Colors.red
                        ),
                        _buildScoreIndicator(
                            'Tidak Dijawab',
                            totalQuestions - correctAnswers - wrongAnswers,
                            Colors.grey
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.grey[300],
                      color: _getScoreColor(score),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getScoreMessage(score),
                      style: TextStyle(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomNavbarScreen(initialIndex: 1), // Set initialIndex ke 1 untuk Ujian
                  ),
                );
              },
              child: const Text('Kembali'),
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