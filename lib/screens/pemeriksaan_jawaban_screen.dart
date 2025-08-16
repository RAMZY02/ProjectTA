import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/models/user_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class PemeriksaanJawabanScreen extends StatefulWidget {
  final UjianModel examData;
  final UserModel student;
  final String studentClass;

  const PemeriksaanJawabanScreen({super.key, required this.examData, required this.student, required this.studentClass});

  @override
  State<PemeriksaanJawabanScreen> createState() => _PemeriksaanJawabanScreenState();
}

class _PemeriksaanJawabanScreenState extends State<PemeriksaanJawabanScreen> {
  List<int?> scores = [];
  int totalQuestions = 0;
  List<String> jawaban = [];

  @override
  void initState() {
    super.initState();
    // Initialize with null scores
    scores = List<int?>.filled(totalQuestions, null);
    jawaban = List<String>.filled(totalQuestions, '-');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    totalQuestions = widget.examData.jumlahSoal;
    scores = List<int?>.filled(totalQuestions, null);
    jawaban = List<String>.filled(totalQuestions, '-');
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Koreksi Jawaban - ${widget.student.nama}'),
      ),
      body: BlocBuilder<SoalUjianBloc, SoalUjianState>(
        builder: (context, soalState) {

          if (authState is Authenticated && soalState is SoalUjianInitial) {
            Future.microtask(() {
              context.read<SoalUjianBloc>().add(
                  FetchSoalUjian(
                      token: authState.token,
                      ujianId: widget.examData.id,
                      userId: widget.student.id
                  )
              );
            });
          }

          if (soalState is SoalUjianLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (soalState is SoalUjianError) {
            return Center(child: Text(soalState.message));
          }

          if (soalState is SoalUjianLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header informasi ujian
                  Text(
                    'Ujian: ${widget.examData.nama}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text('Kelas: ${widget.studentClass}'),
                  Text('Siswa: ${widget.student.nama}'),
                  const SizedBox(height: 20),

                  // Judul pemeriksaan
                  const Text(
                    'Pemeriksaan Jawaban:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // Daftar soal
                  _buildQuestionList(soalState, context),

                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Validasi semua nilai telah diisi
                        if (scores.any((score) => score == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harap isi semua nilai terlebih dahulu')),
                          );
                          return;
                        }

                        // Hitung nilai rata-rata
                        final totalScore = scores.fold<int>(0, (sum, score) => sum + (score ?? 0)) ~/ scores.length;

                        // Kembali ke layar sebelumnya dengan total nilai
                        Navigator.pop(context, totalScore);
                      },
                      child: const Text('Selesai Koreksi'),
                    ),
                  ),
                ],
              ),
            );
          }

          // Default return jika state tidak dikenali
          return const Center(child: Text("Memuat data..."));
        },
      )
    );
  }

  Widget _buildQuestionList(SoalUjianLoaded soalState, BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: soalState.soalList.length,
      itemBuilder: (context, index) {
        final soal = soalState.soalList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soal No. ${index + 1} - ${soal.tipe}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(soal.soal),
                const SizedBox(height: 8),
                if (soal.tipe == 'Pilihan Ganda')
                  if(soal.jawabanSiswa == "A")
                    Text('A. ${soal.opsiA}')
                  else if(soal.jawabanSiswa == "B")
                    Text('B. ${soal.opsiB}')
                  else if(soal.jawabanSiswa == "C")
                    Text('C. ${soal.opsiC}')
                  else if(soal.jawabanSiswa == "D")
                    Text('D. ${soal.opsiD}')
                  else if(soal.jawabanSiswa == "E")
                    Text('E. ${soal.opsiE}'),
                if(soal.tipe != 'Pilihan Ganda')
                  Text(soal.jawabanSiswa),
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
                          scores[index] = int.tryParse(value);
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
    );
  }
}