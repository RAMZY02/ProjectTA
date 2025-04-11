import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'hasilUjian_screen.dart';

class SoalUjianScreen extends StatefulWidget {
  final List<Map<String, dynamic>> soalList;
  final int durationMinutes;

  const SoalUjianScreen({
    super.key,
    required this.soalList,
    this.durationMinutes = 120,
  });

  @override
  State<SoalUjianScreen> createState() => _SoalUjianScreenState();
}

class _SoalUjianScreenState extends State<SoalUjianScreen> with WidgetsBindingObserver {
  late List<Map<String, dynamic>> _shuffledQuestions;
  int currentIndex = 0;
  List<dynamic> jawabanSiswa = [];
  late Timer _examTimer;
  Duration _remainingTime = Duration.zero;
  bool _isSubmitting = false;
  bool _examLocked = true;
  final TextEditingController _exitCodeController = TextEditingController();
  final _exitCode = "654321";
  bool _showingExitDialog = false;
  int _backgroundCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Acak soal
    _shuffledQuestions = List.from(widget.soalList)..shuffle(Random());

    // Initialize jawaban
    jawabanSiswa = List.generate(widget.soalList.length, (index) => null);

    // Initialize timer
    _remainingTime = Duration(minutes: widget.durationMinutes);
    _startTimer();
  }

  @override
  void dispose() {
    _examTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _exitCodeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_examLocked || _showingExitDialog) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _backgroundCount++;

      // If this is the second time going to background, auto-submit
      if (_backgroundCount >= 2) {
        _autoSubmitExam();
      } else {
        _showContinueExamDialog();
      }
    } else if (state == AppLifecycleState.resumed) {
      // If we're returning after auto-submit, go to results screen
      if (_backgroundCount >= 2 && !_isSubmitting) {
        _submitExam();
      }
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
    _backgroundCount = 2; // Ensure we stay in submitted state

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

  void _submitExam() {
    // Hitung nilai
    int correctAnswers = 0;
    int wrongAnswers = 0;

    for (int i = 0; i < _shuffledQuestions.length; i++) {
      final soal = _shuffledQuestions[i];
      final jawaban = jawabanSiswa[i];

      if (soal['type'] == 'pilihan_ganda') {
        if (jawaban == soal['jawaban_benar']) {
          correctAnswers++;
        } else if (jawaban != null) {
          wrongAnswers++;
        }
      }
    }

    double score = (correctAnswers / _shuffledQuestions.length) * 100;
    _examLocked = false;

    // Cancel timer if still running
    if (_examTimer.isActive) {
      _examTimer.cancel();
    }

    // Navigate to results screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HasilUjianScreen(
          score: score,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          totalQuestions: _shuffledQuestions.length,
        ),
      ),
          (route) => false,
    );
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

  void _showQuestionNavigation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const Text(
              'Navigasi Soal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _shuffledQuestions.length,
                itemBuilder: (context, index) {
                  final isAnswered = jawabanSiswa[index] != null &&
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
                            ? Colors.blue
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

  @override
  Widget build(BuildContext context) {
    final currentSoal = _shuffledQuestions[currentIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "Soal ${currentIndex + 1}/${_shuffledQuestions.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
          backgroundColor: const Color(0xFF1976D2),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _showQuestionNavigation,
              tooltip: 'Navigasi Soal',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: _getTypeColor(currentSoal['type']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTypeLabel(currentSoal['type']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soal ${currentIndex + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(currentSoal['pertanyaan']),
                          const SizedBox(height: 8),
                          _buildQuestionType(currentSoal),
                        ],
                      ),
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
                      child: const Text('Sebelumnya'),
                    ),
                    ElevatedButton(
                      onPressed: currentIndex < _shuffledQuestions.length - 1 ? () {
                        setState(() {
                          currentIndex++;
                        });
                      } : null,
                      child: const Text('Selanjutnya'),
                    ),
                  ],
                ),
              ),
              if (currentIndex == _shuffledQuestions.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      _showConfirmationDialog();
                    },
                    child: const Text(
                      'SELESAIKAN UJIAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildQuestionType(Map<String, dynamic> soal) {
    final questionIndex = _shuffledQuestions.indexOf(soal);

    switch (soal['type']) {
      case 'pilihan_ganda':
        return Column(
          children: List.generate(soal['pilihan'].length, (index) {
            return RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              title: Text(
                soal['pilihan'][index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              value: index, // Nilai unik untuk setiap opsi
              groupValue: jawabanSiswa[questionIndex], // Mengambil nilai dari state
              onChanged: (value) {
                setState(() {
                  jawabanSiswa[questionIndex] = value; // Update state saat dipilih
                });
              },
            );
          }),
        );
      case 'essay':
        return TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Ketik jawaban Anda disini...',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(
              fontSize: 16, // Ukuran font yang diinginkan (dalam sp)
              fontWeight: FontWeight.normal, // Ketebalan font
            ),
          ),
          style: TextStyle(
            fontSize: 16, // Ukuran font yang diinginkan (dalam sp)
            fontWeight: FontWeight.normal, // Ketebalan font
          ),
          onChanged: (value) {
            setState(() {
              jawabanSiswa[questionIndex] = value;
            });
          },
          controller: TextEditingController(text: jawabanSiswa[questionIndex]),
        );
      case 'upload_file':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _uploadFile(questionIndex),
              child: const Text('Pilih File'),
            ),
            const SizedBox(height: 8),
            if (jawabanSiswa[questionIndex] != null)
              Text(
                'File terpilih: ${jawabanSiswa[questionIndex]['name']}',
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 8),
            Text(
              'Format file: ${soal['allowed_formats'] ?? 'PDF, DOC, JPG, PNG'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      default:
        return const Text('Jenis soal tidak dikenali');
    }
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
        jawabanSiswa[questionIndex] = result;
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'pilihan_ganda': return Colors.blue;
      case 'essay': return Colors.green;
      case 'upload_file': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'pilihan_ganda': return 'PILIHAN GANDA';
      case 'essay': return 'ESSAY';
      case 'upload_file': return 'UPLOAD FILE';
      default: return 'UNKNOWN';
    }
  }
}