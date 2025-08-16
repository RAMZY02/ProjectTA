import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_bloc.dart';
import 'package:project_ta/bloc/jawaban_siswa/jawaban_siswa_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/hasil_ujian_diperiksa_screen.dart';
import 'package:project_ta/widgets/audio_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:async';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';
import '../bloc/mengikuti_ujian/mengikuti_ujian_bloc.dart';
import '../bloc/mengikuti_ujian/mengikuti_ujian_event.dart';
import '../bloc/soal_ujian/soal_ujian_bloc.dart';
import '../bloc/soal_ujian/soal_ujian_state.dart';
import '../models/soal_model.dart';
import '../widgets/camera_screen.dart';
import '../widgets/video_player.dart';
import 'hasil_ujian_screen.dart';

class SoalUjianScreen extends StatefulWidget {
  final UjianModel ujian;
  final Duration durationMinutes;

  const SoalUjianScreen({
    super.key,
    required this.ujian,
    required this.durationMinutes,
  });

  @override
  State<SoalUjianScreen> createState() => _SoalUjianScreenState();
}

class _SoalUjianScreenState extends State<SoalUjianScreen> with WidgetsBindingObserver {
  int currentIndex = 0;
  List<String> jawabanSiswa = [];
  late Timer _examTimer;
  Duration _remainingTime = Duration.zero;
  bool _isSubmitting = false;
  bool _examLocked = true;
  final TextEditingController _exitCodeController = TextEditingController();
  final _exitCode = "654321";
  bool _showingExitDialog = false;
  int _backgroundCount = 0;
  final Map<int, TextEditingController> _textControllers = {};
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: []
    );

    // Initialize timer
    calculateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _examTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _exitCodeController.dispose();
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_examLocked || _showingExitDialog) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _backgroundCount++;

      if (_backgroundCount >= 2) {
        _autoSubmitExam();
      } else {
        _showContinueExamDialog();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundCount >= 2 && !_isSubmitting) {
        _submitExam();
      }
    }
  }

  void calculateRemainingTime() {
    // Dapatkan waktu sekarang
    final now = DateTime.now();

    // Buat DateTime untuk waktu selesai ujian
    final selesaiDateTime = DateTime(
      widget.ujian.tanggal.year,
      widget.ujian.tanggal.month,
      widget.ujian.tanggal.day,
      widget.ujian.selesai.hour,
      widget.ujian.selesai.minute,
    );

    // Hitung selisih waktu
    final difference = selesaiDateTime.difference(now);

    // Konversi ke menit dan pastikan tidak negatif
    _remainingTime = difference;

    // Update UI jika perlu
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds == 0) {
        timer.cancel();
        _autoSubmitExam();
      } else {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _autoSubmitExam() {
    if (_isSubmitting) return;
    _isSubmitting = true;

    if(_backgroundCount >= 2){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Peringatan Pelanggaran'),
          content: const Text('Anda telah keluar dari aplikasi selama ujian. '
              'Ujian akan otomatis disubmit dan Anda tidak dapat melanjutkan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitExam();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    else{
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Waktu habis'),
          content: const Text('waktu ujian telah habis ujian anda akan otomatis disubmit'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitExam();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

  }

  void _submitExam() {
    final state = context.read<SoalUjianBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (state is! SoalUjianLoaded) return;

    if(authState is Authenticated){
      context.read<MengikutiUjianBloc>().add(UpdateMengikutiUjian(token: authState.token, userId: authState.id, ujianId: widget.ujian.id));
    }

    int pilihanGandaCorrect = 0;
    int pilihanGandaWrong = 0;
    int pilihanGandaTotal = 0;

    for (int i = 0; i < state.soalList.length; i++) {
      final soal = state.soalList[i];
      final jawaban = jawabanSiswa[i];

      if (soal.tipe == 'Pilihan Ganda') {
        pilihanGandaTotal++;
        if (jawaban.toLowerCase() == soal.jawaban.toLowerCase()) {
          pilihanGandaCorrect++;
        } else if (jawaban.isNotEmpty) {
          pilihanGandaWrong++;
        }
      }
    }

    double pilihanGandaScore = pilihanGandaTotal > 0
        ? (pilihanGandaCorrect / pilihanGandaTotal) * 100
        : 0;

    _examLocked = false;
    if (_examTimer.isActive) _examTimer.cancel();

    if(widget.ujian.tipe_soal == 'Pilihan Ganda'){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HasilUjianScreen(
            pilihanGandaScore: pilihanGandaScore,
            pilihanGandaCorrect: pilihanGandaCorrect,
            pilihanGandaWrong: pilihanGandaWrong,
            pilihanGandaTotal: pilihanGandaTotal,
            ujian : widget.ujian
          ),
        ),
            (route) => false,
      );
    }
    else{
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HasilUjianDiperiksaScreen(),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return BlocBuilder<SoalUjianBloc, SoalUjianState>(
      builder: (context, state) {

        if(authState is Authenticated && state is SoalUjianInitial){
          Future.microtask((){
            context.read<SoalUjianBloc>().add(FetchSoalUjian3(token: authState.token, ujianId: widget.ujian.id, userId: authState.id));
          });
        }

        if (state is SoalUjianLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is SoalUjianError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        } else if (state is SoalUjianLoaded) {
          if (jawabanSiswa.isEmpty) {
            jawabanSiswa = List.generate(state.soalList.length, (index) => '');
            for (int i = 0; i < state.soalList.length; i++) {
              if (state.soalList[i].jawabanSiswa != '-' || state.soalList[i].jawabanSiswa != '') {
                jawabanSiswa[i] = state.soalList[i].jawabanSiswa;
              } else {
                jawabanSiswa[i] = '';
              }
            }
          }

          final currentSoal = state.soalList[currentIndex];
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    Text(
                      "Soal ${currentIndex + 1}/${state.soalList.length}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sisa Waktu: ${_remainingTime.inHours}:${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                backgroundColor: kPrimaryColor,
                iconTheme: const IconThemeData(color: Colors.white, size: 20),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: _showQuestionNavigation,
                    tooltip: 'Navigasi Soal',
                  ),
                ],
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.grey,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _getTypeColor(currentSoal.tipe),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTypeLabel(currentSoal.tipe),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 16, top: 12, right: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Soal ${currentIndex + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Preview Media
                                      if (currentSoal.linkVideo != '-' && currentSoal.linkVideo.isNotEmpty)
                                        _buildVideoPreview(currentSoal.linkVideo),

                                      if (currentSoal.linkGambar != '-' && currentSoal.linkGambar.isNotEmpty)
                                        _buildImagePreview(currentSoal.linkGambar),

                                      if (currentSoal.linkAudio != '-' && currentSoal.linkAudio.isNotEmpty)
                                        AudioPreviewWidget(audioUrl: currentSoal.linkAudio),

                                      const SizedBox(height: 8),
                                      Text(
                                          currentSoal.soal,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)
                                      ),
                                    ],
                                  ),
                              ),
                              const SizedBox(height: 4),
                              _buildQuestionType(currentSoal, authState),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: currentIndex > 0 ? () {
                              if(authState is Authenticated){
                                if(currentSoal.tipe == "Isian"){
                                  context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: currentSoal.id, jawaban: jawabanSiswa[currentIndex], nilai: 0, userId: authState.id));
                                }
                              }
                              setState(() {
                                currentIndex--;
                              });
                            } : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 35),
                            ),
                            child: const Text('Sebelumnya', style: TextStyle(fontSize: 14)),
                          ),
                          ElevatedButton(
                            onPressed: currentIndex < state.soalList.length - 1 ? () {
                              if(authState is Authenticated){
                                if(currentSoal.tipe == "Isian"){
                                  context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: currentSoal.id, jawaban: jawabanSiswa[currentIndex], nilai: 0, userId: authState.id));
                                }
                              }
                              setState(() {
                                currentIndex++;
                              });
                            } : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 35),
                            ),
                            child: const Text('Selanjutnya'),
                          ),
                        ],
                      ),
                    ),
                    if (currentIndex == state.soalList.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          onPressed: () {
                            _showConfirmationDialog();
                          },
                          child: const Text(
                            'SELESAIKAN UJIAN',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildQuestionType(SoalModel soal, AuthState authState) {
    final questionIndex = context.read<SoalUjianBloc>().state is SoalUjianLoaded
        ? (context.read<SoalUjianBloc>().state as SoalUjianLoaded)
        .soalList
        .indexOf(soal)
        : 0;

    switch (soal.tipe) {
      case 'Pilihan Ganda':
      // Create list of options from the soal object
        final List<String?> options = [
          soal.opsiA,
          soal.opsiB,
          soal.opsiC,
          soal.opsiD,
          soal.opsiE,
        ].where((option) => option.isNotEmpty).toList();

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 4, right: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            // Get option label (A, B, C, D, E)
            final optionLabel = String.fromCharCode(65 + index); // 65 is ASCII for 'A'

            return InkWell(
              onTap: () {
                if(authState is Authenticated){
                  if(optionLabel == soal.jawaban){
                    context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: soal.id, jawaban: optionLabel, nilai: 10, userId: authState.id));
                  }
                  else{
                    context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: soal.id, jawaban: optionLabel, nilai: 0, userId: authState.id));
                  }
                }
                setState(() {
                  jawabanSiswa[questionIndex] = optionLabel;
                });
              },
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio<String>(
                        value: optionLabel,
                        groupValue: jawabanSiswa[questionIndex],
                        onChanged: (value) {
                          if(authState is Authenticated){
                            if(optionLabel == soal.jawaban){
                              context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: soal.id, jawaban: optionLabel, nilai: 10, userId: authState.id));
                            }
                            else{
                              context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: soal.id, jawaban: optionLabel, nilai: 0, userId: authState.id));
                            }
                          }
                          setState(() {
                            jawabanSiswa[questionIndex] = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      // Display option label (A, B, C, etc.)
                      Text(
                        '$optionLabel.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          options[index] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      case 'Isian':
      // Initialize controller if not exists
        if (!_textControllers.containsKey(questionIndex)) {
          _textControllers[questionIndex] = TextEditingController(
            text: jawabanSiswa[questionIndex],
          );
        } else {
          // Update controller text if the value changed externally
          if (_textControllers[questionIndex]!.text != jawabanSiswa[questionIndex]) {
            _textControllers[questionIndex]!.text = jawabanSiswa[questionIndex];
          }
        }

        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: TextField(
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Ketik jawaban Anda disini...',
              border: OutlineInputBorder(),
            ),
            controller: _textControllers[questionIndex],
            onChanged: (value) {
              setState(() {
                jawabanSiswa[questionIndex] = value;
              });
            },
          ),
        );
      case 'Upload File':
        return Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => showCustomFilePicker(context, questionIndex, soal),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    maximumSize: const Size(double.infinity, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: const Text(
                    'Pilih File dari Aplikasi',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                BlocListener<CloudflareBloc, CloudflareState>(
                  listener: (context, state) {
                    if (state is CloudFlareLoaded) {
                      // Only update the state when the upload is successful
                      setState(() {
                        isloading = false;
                        jawabanSiswa[questionIndex] = 'https://edukasiin.animein.net/${state.fileName}';
                      });
                    }
                    else if (state is CloudFlareLoading){
                      setState(() {
                        isloading = true;
                        jawabanSiswa[questionIndex] = '';
                      });
                    }
                    else if (state is CloudFlareError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload failed: ${state.message}')),
                      );
                      setState(() {
                        jawabanSiswa[questionIndex] = '';
                      });
                    }
                  },
                  child: Column(
                    children: [
                      if(isloading)...[
                        Center(child: CircularProgressIndicator()),
                        SizedBox(height: 4),
                        Center(child: Text('Uploading...')),
                        SizedBox(height: 8)
                      ],
                      if (jawabanSiswa[questionIndex] != '')...[
                        Text(
                          'File terpilih:',
                          style: const TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        if(jawabanSiswa[questionIndex].contains('.mp4'))
                          _buildVideoPreview(jawabanSiswa[questionIndex]),

                        if (jawabanSiswa[questionIndex].contains('.jpg') || jawabanSiswa[questionIndex].contains('.png'))
                          _buildImagePreview(jawabanSiswa[questionIndex]),

                        if (jawabanSiswa[questionIndex].contains('.mp3'))
                          AudioPreviewWidget(audioUrl: jawabanSiswa[questionIndex]),

                        if (jawabanSiswa[questionIndex].contains('.pdf'))
                          SizedBox(
                            height: 450, // Atur tinggi sesuai kebutuhan
                            child: _buildFilePreview(jawabanSiswa[questionIndex]),
                          ),
                        SizedBox(height: 8)
                      ],
                      Text(
                        'Format file: PDF, JPG, PNG, MP3, MP4',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            )
        );
      case 'Upload Foto':
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Column(
            children: [
              if (jawabanSiswa[questionIndex] == '')...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    maximumSize: const Size(double.infinity, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  onPressed: () async {
                    final imagePath = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          soal: soal,
                          questionIndex: questionIndex,
                        ),
                      ),
                    );

                    if (imagePath != null) {
                      setState(() {
                        jawabanSiswa[questionIndex] = imagePath;
                      });
                    }
                  },
                  child: Text('Buka Kamera'),
                ),
              ],
              BlocListener<CloudflareBloc, CloudflareState>(
                listener: (context, state) {
                  if (state is CloudFlareLoaded) {
                    // Only update the state when the upload is successful
                    setState(() {
                      isloading = false;
                      jawabanSiswa[questionIndex] = 'https://edukasiin.animein.net/${state.fileName}';
                    });
                  }
                  else if (state is CloudFlareLoading){
                    setState(() {
                      isloading = true;
                      jawabanSiswa[questionIndex] = '';
                    });
                  }
                  else if (state is CloudFlareError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed: ${state.message}')),
                    );
                    setState(() {
                      jawabanSiswa[questionIndex] = '';
                    });
                  }
                },
                child: Column(
                  children: [
                    if(isloading)...[
                      Center(child: CircularProgressIndicator()),
                      SizedBox(height: 4),
                      Center(child: Text('Uploading...')),
                      SizedBox(height: 8)
                    ]
                    else if (jawabanSiswa[questionIndex] != '') ...[
                      _buildImagePreview(jawabanSiswa[questionIndex]),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            jawabanSiswa[questionIndex] = '';
                          });
                        },
                        child: Text('Ambil Ulang'),
                      ),
                    ],
                  ],
                )
              ),
            ],
          ),
        );
      default:
        return const Text('Jenis soal tidak dikenali');
    }
  }

  Future<bool> _onWillPop() async {
    if (!_examLocked) return true;

    final result = await _showExitConfirmationDialog();
    return result ?? false;
  }

  Future<bool?> _showExitConfirmationDialog() async {
    _showingExitDialog = true;
    _exitCodeController.clear();

    try {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Keluar Ujian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan kode dari guru untuk keluar ujian:'),
              const SizedBox(height: 16),
              TextField(
                controller: _exitCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '6 digit kode',
                ),
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_exitCodeController.text == _exitCode) {
                  _examLocked = false;
                  Navigator.pop(context, true); // Keluar
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kode salah! Silakan coba lagi.'),
                        duration: Duration(seconds: 2),
                      )
                  );
                }
              },
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
    } finally {
      _showingExitDialog = false;
    }
  }

  void _showQuestionNavigation() {
    final state = context.read<SoalUjianBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (state is! SoalUjianLoaded) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const Text(
              'Navigasi Soal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(height: 20, thickness: 2, indent: 120, endIndent: 120),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.soalList.length,
                itemBuilder: (context, index) {
                  final isAnswered = jawabanSiswa[index] != '' && jawabanSiswa[index].isNotEmpty;
                  return InkWell(
                    onTap: () {
                      if(authState is Authenticated){
                        if(state.soalList[currentIndex].tipe == "Isian"){
                          context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.ujian.id, soalId: state.soalList[currentIndex].id, jawaban: jawabanSiswa[currentIndex], nilai: 0, userId: authState.id));
                        }
                      }
                      setState(() {
                        currentIndex = index;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? kPrimaryColor
                            : isAnswered
                            ? Colors.green
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: currentIndex == index || isAnswered
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContinueExamDialog() async {
    if (_showingExitDialog) return;
    _showingExitDialog = true;
    _exitCodeController.clear();

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Ujian Sedang Berlangsung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Anda dilarang keluar aplikasi selama ujian berlangsung. '
                      'Untuk melanjutkan ujian, masukkan kode dari guru:'
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _exitCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '6 digit kode',
                ),
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_exitCodeController.text == _exitCode) {
                  Navigator.pop(context);
                  _showingExitDialog = false;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kode salah! Silakan coba lagi.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Lanjutkan'),
            ),
            TextButton(
              onPressed: () {
                _submitExam();
              },
              child: const Text('Tolak'),
            ),
          ],
        ),
      ),
    ).then((_) => _showingExitDialog = false);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menyelesaikan ujian? Pastikan semua jawaban sudah terisi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFileSelection(File file, int questionIndex, SoalModel soal, BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      // Tentukan content type
      final contentType = _getContentType(file.path);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Jawaban/${questionIndex + 1}-$timestamp${_extension(file.path)}';

      // Upload file
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileContent: file,
          contentType: contentType,
          token: authState.token,
        ),
      );

      // Update jawaban
      context.read<JawabanSiswaBloc>().add(
        UpdateJawabanSiswa(
          token: authState.token,
          ujianId: widget.ujian.id,
          soalId: soal.id,
          jawaban: 'https://edukasiin.animein.net/$fileName',
          nilai: 0,
          userId: authState.id,
        ),
      );

      Navigator.pop(context); // Tutup file picker
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String _getContentType(String fileName) {
    if (fileName.toLowerCase().endsWith('.png')) return 'image/png';
    if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) return 'image/jpeg';
    if (fileName.toLowerCase().endsWith('.mov')) return 'video/quicktime';
    if (fileName.toLowerCase().endsWith('.mp3')) return 'audio/mpeg';
    if (fileName.toLowerCase().endsWith('.pdf')) return 'application/pdf';
    if (fileName.toLowerCase().endsWith('.mp4')) return 'video/mp4';
    return 'application/octet-stream';
  }

  String _extension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  Future<List<File>> _getFilesWithExtensions(List<String> extensions) async {
    final List<File> files = [];
    final List<Directory> directoriesToSearch = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Documents'),
      Directory('/storage/emulated/0/Pictures'),
      Directory('/storage/emulated/0/DCIM'),
    ];

    for (var dir in directoriesToSearch) {
      if (await dir.exists()) {
        try {
          final list = await dir.list(recursive: true).toList();
          for (var entity in list) {
            if (entity is File) {
              final path = entity.path.toLowerCase();
              if (extensions.any((ext) => path.endsWith(ext))) {
                files.add(entity);
              }
            }
          }
        } catch (e) {
          print('Error accessing ${dir.path}: $e');
        }
      }
    }

    return files;
  }

  void showCustomFilePicker(BuildContext context, int questionIndex, SoalModel soal) async {
    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final allowedExtensions = ['pdf', 'mp3', 'mp4', 'jpg', 'jpeg', 'png'];
    final files = await _getFilesWithExtensions(allowedExtensions);

    // Tutup loading indicator
    Navigator.of(context).pop();

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ditemukan file yang sesuai')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Text(
                'Pilih File',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ListTile(
                      leading: _getFileIcon(file.path),
                      title: Text(file.path.split('/').last),
                      subtitle: Text(file.parent.path),
                      onTap: () {
                        Navigator.pop(context);
                        _handleFileSelection(file, questionIndex, soal, context);
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    final iconSize = 40.0;

    switch (ext) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, size: iconSize, color: Colors.red);
      case 'mp3':
      case 'wav':
        return Icon(Icons.audio_file, size: iconSize, color: Colors.blue);
      case 'mp4':
      case 'mov':
        return Icon(Icons.video_file, size: iconSize, color: Colors.purple);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icon(Icons.image, size: iconSize, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file, size: iconSize);
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Pilihan Ganda': return Colors.blue;
      case 'Isian': return Colors.green;
      case 'Upload File': return Colors.orange;
      case 'Upload Foto': return Colors.brown;
      default: return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'Pilihan Ganda': return 'PILIHAN GANDA';
      case 'Isian': return 'ISIAN';
      case 'Upload File': return 'UPLOAD FILE';
      case 'Upload Foto': return 'UPLOAD FOTO';
      default: return 'UNKNOWN';
    }
  }

  //preview disini
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

  Widget _buildVideoPreview(String videoUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: VideoPlayerWidget(videoUrl: videoUrl),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String pdfUrl) {
    if (pdfUrl.isEmpty || pdfUrl == '-') {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 600,
      ),
      child: SfPdfViewer.network(
        pdfUrl,
        initialZoomLevel: 1.0,
      ),
    );
  }
}