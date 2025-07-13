import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/constants/color.dart';
import 'dart:async';
import 'dart:math';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/soal_ujian/soal_ujian_bloc.dart';
import '../bloc/soal_ujian/soal_ujian_event.dart';
import '../bloc/soal_ujian/soal_ujian_state.dart';
import '../models/soal_model.dart';
import 'hasil_ujian_screen.dart';

class SoalUjianScreen extends StatefulWidget {
  final int ujianId;
  final Duration durationMinutes;

  const SoalUjianScreen({
    super.key,
    required this.ujianId,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize timer
    _remainingTime = widget.durationMinutes;
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
    if (state is! SoalUjianLoaded) return;

    int pilihanGandaCorrect = 0;
    int pilihanGandaWrong = 0;
    int pilihanGandaTotal = 0;
    int isianTotal = 0;
    int uploadFileTotal = 0;

    for (int i = 0; i < state.soalList.length; i++) {
      final soal = state.soalList[i];
      final jawaban = jawabanSiswa[i] ?? '';

      if (soal.tipe == 'Pilihan Ganda') {
        pilihanGandaTotal++;
        if (jawaban.toLowerCase() == soal.jawaban.toLowerCase()) {
          pilihanGandaCorrect++;
        } else if (jawaban.isNotEmpty) {
          pilihanGandaWrong++;
        }
      } else if (soal.tipe == 'isian') {
        isianTotal++;
      } else if (soal.tipe == 'upload file') {
        uploadFileTotal++;
      }
    }

    double pilihanGandaScore = pilihanGandaTotal > 0
        ? (pilihanGandaCorrect / pilihanGandaTotal) * 100
        : 0;

    _examLocked = false;
    if (_examTimer.isActive) _examTimer.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HasilUjianScreen(
          pilihanGandaScore: pilihanGandaScore,
          pilihanGandaCorrect: pilihanGandaCorrect,
          pilihanGandaWrong: pilihanGandaWrong,
          pilihanGandaTotal: pilihanGandaTotal,
          isianTotal: isianTotal,
          uploadFileTotal: uploadFileTotal,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoalUjianBloc, SoalUjianState>(
      builder: (context, state) {
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
                        fontSize: 10,
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
                                      Text(currentSoal.soal,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                                    ],
                                  )
                              ),
                              const SizedBox(height: 4),
                              _buildQuestionType(currentSoal),
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
                              setState(() {
                                currentIndex--;
                              });
                            } : null,
                            child: const Text('Sebelumnya', style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 35),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: currentIndex < state.soalList.length - 1 ? () {
                              setState(() {
                                currentIndex++;
                              });
                            } : null,
                            child: const Text('Selanjutnya'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 35),
                            ),
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

  Widget _buildQuestionType(SoalModel soal) {
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
        ].where((option) => option != null && option.isNotEmpty).toList();

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
                setState(() {
                  jawabanSiswa[questionIndex] = '$optionLabel';
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
      case 'isian':
      // Initialize controller if not exists
        if (!_textControllers.containsKey(questionIndex)) {
          _textControllers[questionIndex] = TextEditingController(
            text: jawabanSiswa[questionIndex] ?? '',
          );
        } else {
          // Update controller text if the value changed externally
          if (_textControllers[questionIndex]!.text != jawabanSiswa[questionIndex]) {
            _textControllers[questionIndex]!.text = jawabanSiswa[questionIndex] ?? '';
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
      case 'upload file':
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _uploadFile(questionIndex),
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
                  'Pilih File',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              if (jawabanSiswa[questionIndex] != '')
                Text(
                  'File terpilih: ${jawabanSiswa[questionIndex]}',
                  style: const TextStyle(fontSize: 12),
                ),
              Text(
                'Format file: PDF, DOC, JPG, PNG',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          )
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
                  final isAnswered = jawabanSiswa[index] != '' &&
                      (jawabanSiswa[index] is String
                          ? jawabanSiswa[index].isNotEmpty
                          : true);
                  return InkWell(
                    onTap: () {
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
          ],
        ),
      ),
    ).then((_) => _showingExitDialog = false);
  }

  // Method untuk menyimpan jawaban sementara
  // Future<void> _saveTemporaryAnswers() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('temp_exam_answers', jsonEncode(_answers));
  //   } catch (e) {
  //     debugPrint('Error saving temporary answers: $e');
  //   }
  // }

  // Method untuk memuat jawaban yang tersimpan
  // Future<void> _loadTemporaryAnswers() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedAnswers = prefs.getString('temp_exam_answers');
  //     if (savedAnswers != null) {
  //       _answers = Map<String, dynamic>.from(jsonDecode(savedAnswers));
  //       setState(() {}); // Update UI jika perlu
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading temporary answers: $e');
  //   }
  // }


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

  Future<void> _uploadFile(int questionIndex) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Dokumen PDF'),
              onTap: () => Navigator.pop(context, {
                'name': 'document_${questionIndex + 1}.pdf',
                'size': '250 KB',
                'path': '/path/to/file.pdf'
              }),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gambar'),
              onTap: () => Navigator.pop(context, {
                'name': 'image_${questionIndex + 1}.jpg',
                'size': '1.2 MB',
                'path': '/path/to/image.jpg'
              }),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        jawabanSiswa[questionIndex] = result['name'];
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Pilihan Ganda': return Colors.blue;
      case 'isian': return Colors.green;
      case 'upload file': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'Pilihan Ganda': return 'PILIHAN GANDA';
      case 'isian': return 'ISIAN';
      case 'upload file': return 'UPLOAD FILE';
      default: return 'UNKNOWN';
    }
  }
}