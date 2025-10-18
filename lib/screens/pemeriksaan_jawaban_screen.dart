import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/models/user_model.dart';

import '../bloc/WA/WA_bloc.dart';
import '../bloc/WA/WA_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/jawaban_siswa/jawaban_siswa_bloc.dart';
import '../bloc/jawaban_siswa/jawaban_siswa_event.dart';

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
  final List<TextEditingController> _scoreControllers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Koreksi Jawaban - ${widget.student.nama}'),
      ),
      body: SafeArea(
        child: BlocBuilder<SoalUjianBloc, SoalUjianState>(
          builder: (context, soalState) {

            if (authState is Authenticated && soalState is SoalUjianInitial) {
              context.read<SoalUjianBloc>().add(
                  FetchSoalUjian(
                      token: authState.token,
                      ujianId: widget.examData.id,
                      userId: widget.student.id
                  )
              );
            }

            if (soalState is SoalUjianLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (soalState is SoalUjianError) {
              return Center(child: Text(soalState.message));
            }

            if (soalState is SoalUjianLoaded) {
              if (scores.isEmpty) {
                scores = List.generate(soalState.soalList.length, (index) => 0);
                for (int i = 0; i < soalState.soalList.length; i++) {
                  if (soalState.soalList[i].nilaiSiswa != 0) {
                    scores[i] = soalState.soalList[i].nilaiSiswa;
                  } else {
                    scores[i] = 0;
                  }
                  _scoreControllers.add(
                    TextEditingController(
                        text: scores[i].toString()
                    ),
                  );
                }
              }
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
                    _buildQuestionList(soalState, context, authState),

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
                          final totalScore = scores.fold<int>(0, (sum, score) => sum + (score ?? 0)) ~/ (scores.length/10);
                          context.read<UsersBloc>().add(Init());
                          if(authState is Authenticated){
                            final pesan =  'Nilai ${widget.examData.tipe_ujian} Mata Pelajaran ${widget.examData.mapel} anak Anda yang bernama ${widget.student.nama} adalah $totalScore';
                            context.read<WaBloc>().add(SendMessage(pesan: pesan, tujuan: widget.student.nomor_ortu, token: authState.token));
                            context.read<HistoryUjianBloc>().add(UpdateHistoryUjian(token: authState.token, userId: widget.student.id, ujianId: widget.examData.id, nilai: totalScore, kehadiran: 'true', selesai: 'true', diperiksa: 'true'));
                          }
                          // Kembali ke layar sebelumnya dengan total nilai
                          Navigator.pop(context);
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
      )
    );
  }

  Widget _buildQuestionList(SoalUjianLoaded soalState, BuildContext context, AuthState authState) {
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
                if(soal.tipe != 'Pilihan Ganda')...[
                  if(soal.jawabanSiswa.contains('.jpg') || soal.jawabanSiswa.contains('.jpeg') || soal.jawabanSiswa.contains('.png'))...[
                    _buildImagePreview(soal.jawabanSiswa),
                  ]
                  else...[
                    Text(soal.jawabanSiswa),
                  ]
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Nilai: '),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: TextField(
                        controller: _scoreControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          scores[index] = int.tryParse(value);
                        },
                        onTapOutside: (event) {
                          // FocusScope digunakan untuk unfocus keyboard
                          FocusScope.of(context).unfocus();

                          // Panggil event Bloc setelah keyboard ditutup
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if(authState is Authenticated){
                              context.read<JawabanSiswaBloc>().add(
                                  UpdateJawabanSiswa(
                                      token: authState.token,
                                      ujianId: soal.idUjian,
                                      soalId: soal.id,
                                      jawaban: soal.jawabanSiswa,
                                      nilai: scores[index] ?? 0, // Gunakan nilai yang sudah diinput
                                      userId: widget.student.id
                                  )
                              );
                            }
                          });
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

  Widget _buildImagePreview(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
              child: child,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}