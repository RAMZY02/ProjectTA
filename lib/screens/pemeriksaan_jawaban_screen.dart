import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_event.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_state.dart';
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
        builder: (context, soalState){
          if (authState is Authenticated &&
              (soalState is! SoalUjianLoaded || soalState.soalList.isEmpty)) {
            Future.microtask(() {
              context.read<SoalUjianBloc>().add(FetchSoalUjian(token: authState.token, ujianId: widget.examData.id));
            });
          }
          if(soalState is SoalUjianLoaded){
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ujian: ${widget.examData.nama}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text('Kelas: ${widget.studentClass}'),
                  Text('Siswa: ${widget.student.nama}'),
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
                      final soal = soalState.soalList[index];
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
                              Text(soal.soal),
                              const SizedBox(height: 8),
                              BlocBuilder<JawabanSiswaBloc, JawabanSiswaState>(
                                builder: (context, jawabanState){

                                  if (authState is Authenticated && (jawabanState is! JawabanSiswaLoaded)) {
                                    Future.microtask(() {
                                      context.read<JawabanSiswaBloc>().add(FetchJawabanSiswa(token: authState.token, userId: widget.student.id, ujianId: widget.examData.id, soalId: soal.id));
                                    });
                                  }

                                  if(jawabanState is JawabanSiswaLoaded){
                                    jawaban[index] = jawabanState.jawaban.jawaban;
                                    if(soal.tipe == 'Pilihan Ganda'){
                                      if(jawaban[index] == 'A'){
                                        return Text('Jawaban siswa: A. ${soal.opsiA}');
                                      }
                                      else if(jawaban[index] == 'B'){
                                        return Text('Jawaban siswa: B. ${soal.opsiB}');
                                      }
                                      else if(jawaban[index] == 'C'){
                                        return Text('Jawaban siswa: C. ${soal.opsiC}');
                                      }
                                      else if(jawaban[index] == 'D'){
                                        return Text('Jawaban siswa: D. ${soal.opsiD}');
                                      }
                                      else{
                                        return Text('Jawaban siswa: E. ${soal.opsiE}');
                                      }
                                    }
                                    else{
                                      return Text('Jawaban siswa: ${jawaban[index]}');
                                    }
                                  }
                                  else if (jawabanState is JawabanSiswaLoading) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  else if (jawabanState is JawabanSiswaError) {
                                    return Center(child: Text(jawabanState.message));
                                  }
                                  else {
                                    return const Center(child: Text(""));
                                  }
                                }
                              ),
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
            );
          }
          else if (soalState is SoalUjianLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (soalState is SoalUjianError) {
            return Center(child: Text(soalState.message));
          }
          else {
            return const Center(child: Text(""));
          }
        }
      )
    );
  }
}