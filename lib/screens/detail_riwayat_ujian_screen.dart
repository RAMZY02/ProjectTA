import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/history_ujian_model.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/models/soal_model.dart';

class DetailRiwayatUjianScreen extends StatelessWidget {
  final HistoryUjianModel exam;

  const DetailRiwayatUjianScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Riwayat Ujian',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header informasi ujian
            _buildExamSummary(context),
            const SizedBox(height: 24),
            // Daftar soal
            const Text(
              'Detail Jawaban',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<SoalUjianBloc, SoalUjianState>(
                builder: (context, soalState){
                  if(authState is Authenticated && soalState is SoalUjianInitial){
                    context.read<SoalUjianBloc>().add(FetchSoalUjian(token: authState.token, ujianId: exam.id, userId: authState.id));
                  }

                  if(soalState is SoalUjianLoaded){
                    if(soalState.soalList.isEmpty){
                      return Center(child: Text("Belum ada soal yang tersedia"));
                    }
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: exam.ujian.jumlahSoal,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final question = soalState.soalList[index];
                        final answer = soalState.soalList[index].jawabanSiswa;
                        return _buildQuestionCard(question, answer, index + 1);
                      },
                    );
                  }
                  else if(soalState is SoalUjianLoading){
                    return Center(child: CircularProgressIndicator());
                  }
                  else{
                    return Text("Login dulu bang");
                  }
                }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExamSummary(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exam.ujian.mapel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(exam.nilai),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exam.nilai}',
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
              'Tipe Ujian: ${exam.ujian.tipe_ujian}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Jenis Soal: ${exam.ujian.tipe_soal}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal: ${exam.ujian.tanggal.toString().substring(0, 10)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: exam.nilai / 100,
              backgroundColor: Colors.grey[200],
              color: _getScoreColor(exam.nilai),
              minHeight: 6,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(SoalModel question, String answer, int questionNumber) {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: question.nilaiSiswa == 0 ? Colors.red : Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    questionNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.soal,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: question.nilaiSiswa == 0 ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${question.nilaiSiswa}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            if(question.tipe == "Pilihan Ganda")...[
              const SizedBox(height: 12),
              // Opsi jawaban
              _buildOption('A. ${question.opsiA}', 'A', question.jawaban, answer),
              _buildOption('B. ${question.opsiB}', 'B', question.jawaban, answer),
              _buildOption('C. ${question.opsiC}', 'C', question.jawaban, answer),
              _buildOption('D. ${question.opsiD}', 'D', question.jawaban, answer),
              _buildOption('E. ${question.opsiE}', 'E', question.jawaban, answer),
            ],
            const SizedBox(height: 12),
            // Jawaban siswa
            Text(
              'Jawaban Anda: $answer',
              style: TextStyle(
                color: question.nilaiSiswa == 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if(question.tipe == "Pilihan Ganda")...[
              const SizedBox(height: 8),
              // Jawaban benar
              Text(
                'Jawaban Benar: ${question.jawaban}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Pembahasan
            if (question.pembahasan.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pembahasan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.pembahasan,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String optionText, String optionValue, String correctAnswer, String studentAnswer) {
    final isCorrectAnswer = optionValue == correctAnswer;
    final isStudentAnswer = optionValue == studentAnswer;
    Color? backgroundColor;

    if (isCorrectAnswer) {
      backgroundColor = Colors.green.withOpacity(0.1);
    } else if (isStudentAnswer && !isCorrectAnswer) {
      backgroundColor = Colors.red.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrectAnswer
              ? Colors.green
              : isStudentAnswer && !isCorrectAnswer
              ? Colors.red
              : Colors.grey[300]!,
          width: isCorrectAnswer || (isStudentAnswer && !isCorrectAnswer) ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(optionText),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    return Colors.red;
  }
}