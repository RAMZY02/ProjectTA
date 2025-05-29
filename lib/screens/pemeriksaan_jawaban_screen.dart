import 'package:flutter/material.dart';

class PemeriksaanJawabanScreen extends StatefulWidget {
  final Map<String, dynamic> examData;
  final Map<String, dynamic> student;
  final String studentClass;

  const PemeriksaanJawabanScreen({super.key, required this.examData, required this.student, required this.studentClass});

  @override
  State<PemeriksaanJawabanScreen> createState() => _PemeriksaanJawabanScreenState();
}

class _PemeriksaanJawabanScreenState extends State<PemeriksaanJawabanScreen> {
  List<int?> scores = [];
  int totalQuestions = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with null scores
    scores = List<int?>.filled(totalQuestions, null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    totalQuestions = widget.examData['questions'];
    scores = List<int?>.filled(totalQuestions, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koreksi Jawaban - ${widget.student['name']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ujian: ${widget.examData['title']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Kelas: $widget.studentClass'),
            Text('Siswa: ${widget.student['name']}'),
            const SizedBox(height: 20),
            const Text(
              'Pemeriksaan Jawaban:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            // List of questions and answer fields
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalQuestions,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soal No. ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Jawaban siswa: Lorem ipsum dolor sit amet...'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Nilai: '),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    scores[index] = int.tryParse(value);
                                  } else {
                                    scores[index] = null;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Calculate total score
                  final validScores = scores.where((score) => score != null).toList();
                  if (validScores.length != totalQuestions) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap isi semua nilai terlebih dahulu')),
                    );
                    return;
                  }

                  final totalScore = validScores.reduce((a, b) => a! + b!)! ~/ totalQuestions;

                  // Return to previous screen with the total score
                  Navigator.pop(context, totalScore);
                },
                child: const Text('Selesai Koreksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}