import 'package:flutter/material.dart';
import 'package:project_ta/constants/color.dart';
import 'package:intl/intl.dart';

class RiwayatUjianScreen extends StatelessWidget {
  const RiwayatUjianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Ujian'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: examHistory.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final exam = examHistory[index];
          return _buildExamCard(context, exam);
        },
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, ExamHistory exam) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke detail riwayat ujian
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exam.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(exam.score),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exam.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Jenis: ${exam.examType}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(exam.date)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: exam.score / 100,
                backgroundColor: Colors.grey[200],
                color: _getScoreColor(exam.score),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    return Colors.red;
  }
}

class ExamHistory {
  final String subject;
  final String examType;
  final DateTime date;
  final int score;

  ExamHistory({
    required this.subject,
    required this.examType,
    required this.date,
    required this.score,
  });
}

final List<ExamHistory> examHistory = [
  ExamHistory(
    subject: 'Matematika',
    examType: 'Ujian Harian',
    date: DateTime(2024, 4, 15),
    score: 85,
  ),
  ExamHistory(
    subject: 'Bahasa Indonesia',
    examType: 'UTS',
    date: DateTime(2024, 3, 28),
    score: 78,
  ),
  ExamHistory(
    subject: 'IPA',
    examType: 'Ujian Harian',
    date: DateTime(2024, 3, 20),
    score: 92,
  ),
  ExamHistory(
    subject: 'IPS',
    examType: 'Remedial',
    date: DateTime(2024, 3, 10),
    score: 55,
  ),
  ExamHistory(
    subject: 'Bahasa Inggris',
    examType: 'Ujian Harian',
    date: DateTime(2024, 2, 25),
    score: 68,
  ),
];