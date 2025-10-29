import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/models/soal_model.dart';
import 'package:project_ta/models/ujian_model.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';
import '../widgets/audio_player.dart';
import '../widgets/math_notation_widget.dart';
import '../widgets/video_player.dart';
import 'insert_soal_dan_jawaban_screen.dart';

class MembuatSoalScreen extends StatefulWidget {
  final UjianModel ujian;

  const MembuatSoalScreen({super.key, required this.ujian});

  @override
  State<MembuatSoalScreen> createState() => _MembuatSoalScreenState();
}

class _MembuatSoalScreenState extends State<MembuatSoalScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CloudflareBloc(),
      child: _MembuatSoalScreenContent(ujian: widget.ujian),
    );
  }
}

class _MembuatSoalScreenContent extends StatefulWidget {
  final UjianModel ujian;

  const _MembuatSoalScreenContent({required this.ujian});

  @override
  State<_MembuatSoalScreenContent> createState() => _MembuatSoalScreenContentState();
}

class _MembuatSoalScreenContentState extends State<_MembuatSoalScreenContent> {
  final TextEditingController _questionController = TextEditingController();
  final _questionFocusNode = FocusNode();
  final TextEditingController _optionAController = TextEditingController();
  final _optionAFocusNode = FocusNode();
  final TextEditingController _optionBController = TextEditingController();
  final _optionBFocusNode = FocusNode();
  final TextEditingController _optionCController = TextEditingController();
  final _optionCFocusNode = FocusNode();
  final TextEditingController _optionDController = TextEditingController();
  final _optionDFocusNode = FocusNode();
  final TextEditingController _optionEController = TextEditingController();
  final _optionEFocusNode = FocusNode();
  final TextEditingController _explanationController = TextEditingController();
  final _explanationFocusNode = FocusNode();
  final TextEditingController _mathNotationController = TextEditingController();
  // Tambahkan controller dan variabel baru
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _showAIGenerator = false;
  String _aiQuestionType = 'Pilihan Ganda'; // Tambahkan variabel ini

  String? _selectedAnswer;
  String _questionType = 'Pilihan Ganda';
  String? _imagePath;
  String? _audioPath;
  String? _videoPath;
  String? _imagePathPembahasan;
  String? _audioPathPembahasan;
  String? _videoPathPembahasan;
  bool _showMathNotations = false;
  int _currentMathPage = 0; // Tambahkan ini untuk pagination
  List<String> mathNotations = [
    // Simbol umum
    '±', '∞', '=', '≠', '∼', '×', '÷', '!', '%',

    // Simbol perbandingan
    '<', '>', '≤', '≥', '≪', '≫', '≈', '≡',

    // Simbol himpunan/logika
    '∀', '∃', '⊂', '⊆', '⊃', '⊇', '∈', '∉', '∪', '∩', '∖', '∆', '∅', 'ℕ', 'ℤ', 'ℚ', 'ℝ', 'ℂ',

    // Huruf Yunani
    'α', 'β', 'γ', 'δ', 'ε', 'θ', 'μ', 'π', 'ρ', 'σ', 'τ', 'φ', 'ω', 'ψ', 'Δ',

    // Operator matematika
    '+', '−', '·', '*', ':', '∂', '∫', '∑', '∏',

    // Akar
    '√', '∛', '∜',

    // Satuan/simbol khusus
    '°F', '°C', 'ℎ', 'C', 'V', 'U',

    // Panah
    '←', '↑', '→', '↓',

    // Simbol lain
    '⋯', '…', '■'
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    // Set tipe soal default berdasarkan ujian.tipesoal
    if (widget.ujian.tipe_soal != 'Campuran') {
      _questionType = widget.ujian.tipe_soal;
      _aiQuestionType = widget.ujian.tipe_soal;
    }

    if(authState is Authenticated){
      _subjectController.text = authState.mapel;
    }
  }

  Widget _buildMediaGridSoal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom berdasarkan lebar layar
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3; // Layar besar (desktop)
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2; // Layar sedang (tablet)
        } else {
          crossAxisCount = 1; // Layar kecil (mobile)
        }

        // Kumpulkan semua media yang ada
        List<Widget> mediaWidgets = [];

        // Untuk gambar
        if (_imagePath != null &&
            _imagePath != 'Uploading...' &&
            _imagePath != '-') {
          String imageUrl = _imagePath!.startsWith('http')
              ? _imagePath!
              : 'https://edukasiin.animein.net/$_imagePath';
          mediaWidgets.add(_buildImagePreview(imageUrl));
        } else if (_imagePath == 'Uploading...') {
          mediaWidgets.add(
              const Center(child: Text("Uploading..."))
          );
        }

        // Untuk video
        if (_videoPath != null &&
            _videoPath != 'Uploading...' &&
            _videoPath != '-') {
          String videoUrl = _videoPath!.startsWith('http')
              ? _videoPath!
              : 'https://edukasiin.animein.net/$_videoPath';
          mediaWidgets.add(_buildVideoPreview(videoUrl));
        } else if (_videoPath == 'Uploading...') {
          mediaWidgets.add(
              const Center(child: Text("Uploading..."))
          );
        }

        // Untuk audio
        if (_audioPath != null &&
            _audioPath != 'Uploading...' &&
            _audioPath != '-') {
          String audioUrl = _audioPath!.startsWith('http')
              ? _audioPath!
              : 'https://edukasiin.animein.net/$_audioPath';
          mediaWidgets.add(_buildAudioPreview(audioUrl));
        } else if (_audioPath == 'Uploading...') {
          mediaWidgets.add(
              const Center(child: Text("Uploading..."))
          );
        }

        // Jika tidak ada media yang valid
        if (mediaWidgets.isEmpty) {
          return const SizedBox.shrink();
        }

        // Tampilkan dalam grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _getAspectRatio(crossAxisCount),
          ),
          itemCount: mediaWidgets.length,
          itemBuilder: (context, index) {
            return mediaWidgets[index];
          },
        );
      },
    );
  }

  Widget _buildMediaGridPembahasan() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom berdasarkan lebar layar
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3; // Layar besar (desktop)
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2; // Layar sedang (tablet)
        } else {
          crossAxisCount = 1; // Layar kecil (mobile)
        }

        // Kumpulkan semua media yang ada
        List<Widget> mediaWidgets = [];

        // Untuk gambar
        if (_imagePathPembahasan != null &&
            _imagePathPembahasan != 'Uploading...' &&
            _imagePathPembahasan != '-') {
          String imageUrl = _imagePathPembahasan!.startsWith('http')
              ? _imagePathPembahasan!
              : 'https://edukasiin.animein.net/$_imagePathPembahasan';
          mediaWidgets.add(_buildImagePreview(imageUrl));
        } else if (_imagePathPembahasan == 'Uploading...') {
          mediaWidgets.add(
              const Center(child: Text("Uploading..."))
          );
        }

        // Untuk video
        if (_videoPathPembahasan != null &&
            _videoPathPembahasan != 'Uploading...' &&
            _videoPathPembahasan != '-') {
          String videoUrl = _videoPathPembahasan!.startsWith('http')
              ? _videoPathPembahasan!
              : 'https://edukasiin.animein.net/$_videoPathPembahasan';
          mediaWidgets.add(_buildVideoPreview(videoUrl));
        } else if (_videoPathPembahasan == 'Uploading...') {
          mediaWidgets.add(
              const Center(child: Text("Uploading..."))
          );
        }

        // Untuk audio
        if (_audioPathPembahasan != null &&
            _audioPathPembahasan != 'Uploading...' &&
            _audioPathPembahasan != '-') {
          String audioUrl = _audioPathPembahasan!.startsWith('http')
              ? _audioPathPembahasan!
              : 'https://edukasiin.animein.net/$_audioPathPembahasan';
          mediaWidgets.add(_buildAudioPreview(audioUrl));
        } else if (_audioPathPembahasan == 'Uploading...') {
          mediaWidgets.add(
              const Center(child: Text("Uploading..."))
          );
        }

        // Jika tidak ada media yang valid
        if (mediaWidgets.isEmpty) {
          return const SizedBox.shrink();
        }

        // Tampilkan dalam grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _getAspectRatio(crossAxisCount),
          ),
          itemCount: mediaWidgets.length,
          itemBuilder: (context, index) {
            return mediaWidgets[index];
          },
        );
      },
    );
  }

  // Widget untuk menampilkan media dalam grid responsive
  Widget _buildMediaGridPembahasanSoal(SoalModel question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom berdasarkan lebar layar
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3; // Layar besar (desktop)
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2; // Layar sedang (tablet)
        } else {
          crossAxisCount = 1; // Layar kecil (mobile)
        }

        // Kumpulkan semua media yang ada
        List<Widget> mediaWidgets = [];

        if (question.linkGambarPembahasan != '-') {
          mediaWidgets.add(_buildImagePreview(question.linkGambarPembahasan));
        }

        if (question.linkVideoPembahasan != '-') {
          mediaWidgets.add(_buildVideoPreview(question.linkVideoPembahasan));
        }

        if (question.linkAudioPembahasan != '-') {
          mediaWidgets.add(_buildAudioPreview(question.linkAudioPembahasan));
        }


        // Tampilkan dalam grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _getAspectRatio(crossAxisCount),
          ),
          itemCount: mediaWidgets.length,
          itemBuilder: (context, index) {
            return mediaWidgets[index];
          },
        );
      },
    );
  }

  Widget _buildMediaGrid(SoalModel question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom berdasarkan lebar layar
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3; // Layar besar (desktop)
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2; // Layar sedang (tablet)
        } else {
          crossAxisCount = 1; // Layar kecil (mobile)
        }

        // Kumpulkan semua media yang ada
        List<Widget> mediaWidgets = [];

        if (question.linkGambar != '-') {
          mediaWidgets.add(_buildImagePreview(question.linkGambar));
        }

        if (question.linkVideo != '-') {
          mediaWidgets.add(_buildVideoPreview(question.linkVideo));
        }

        if (question.linkAudio != '-') {
          mediaWidgets.add(_buildAudioPreview(question.linkAudio));
        }


        // Tampilkan dalam grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _getAspectRatio(crossAxisCount),
          ),
          itemCount: mediaWidgets.length,
          itemBuilder: (context, index) {
            return mediaWidgets[index];
          },
        );
      },
    );
  }

  // Fungsi untuk menentukan aspect ratio berdasarkan jumlah kolom
  double _getAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1:
        return 16 / 9; // Lebar landscape untuk 1 kolom
      case 2:
        return 16 / 9;  // Sedikit lebih persegi untuk 2 kolom
      case 3:
        return 16 / 9;      // Persegi untuk 3 kolom
      default:
        return 16 / 9;
    }
  }

  // Modifikasi widget preview agar lebih responsive
  Widget _buildImagePreview(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
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
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Gagal memuat gambar',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPreview(String videoUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }

  Widget _buildAudioPreview(String audioUrl) {
    return AudioPreviewWidget(audioUrl: audioUrl);
  }

  // Tambahkan fungsi untuk memilih dan upload file
  Future<void> _pickFile(String type, BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      FilePickerResult? result;
      String contentType = 'application/octet-stream';
      String filePrefix = '';

      // Set UI state untuk menunjukkan upload sedang berlangsung
      _setUploadingState(type, true);

      if (type == 'gambar') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        contentType = 'image/jpeg';
        filePrefix = 'Soal/Gambar';
      } else if (type == 'video') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
        contentType = 'video/mp4';
        filePrefix = 'Soal/Video';
      } else if (type == 'audio') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
        contentType = 'audio/mpeg';
        filePrefix = 'Soal/Audio';
      }

      if (type == 'pembahasan_gambar') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        contentType = 'image/jpeg';
        filePrefix = 'Pembahasan/Gambar';
      } else if (type == 'pembahasan_video') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
        contentType = 'video/mp4';
        filePrefix = 'Pembahasan/Video';
      } else if (type == 'pembahasan_audio') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
        contentType = 'audio/mpeg';
        filePrefix = 'Pembahasan/Audio';
      }

      // Jika user membatalkan pemilihan file (result null)
      if (result == null) {
        _resetFileState(type);
        return;
      }

      // Handle untuk platform web
      if (kIsWeb) {
        await _handleWebUpload(result, type, filePrefix, contentType, authState, context);
        return;
      }

      // Handle untuk platform mobile (kode asli)
      await _handleMobileUpload(result, type, filePrefix, contentType, authState, context);

    } catch (e) {
      _handleUploadError(e, type, context);
    }
  }

  // Fungsi untuk handle upload di web
  Future<void> _handleWebUpload(
      FilePickerResult result,
      String type,
      String filePrefix,
      String contentType,
      Authenticated authState,
      BuildContext context,
      ) async {
    try {
      final platformFile = result.files.single;

      // Validasi untuk web
      if (platformFile.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membaca file yang dipilih')),
        );
        _resetFileState(type);
        return;
      }

      // Update content type berdasarkan nama file untuk web
      contentType = _getContentTypeFromFileName(platformFile.name, type);

      // Generate unique filename untuk web
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = _getWebFileExtension(platformFile.name, type);
      final fileName = '$filePrefix/${widget.ujian.nama}-$timestamp$fileExtension';

      // Upload file menggunakan CloudflareBloc untuk web
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileWeb: platformFile.bytes, // Gunakan bytes untuk web
          contentType: contentType,
          token: authState.token,
        ),
      );

      // Tampilkan feedback sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File berhasil diupload')),
      );

    } catch (e) {
      _handleUploadError(e, type, context);
    }
  }

  // Fungsi untuk handle upload di mobile (kode asli dengan improvements)
  Future<void> _handleMobileUpload(
      FilePickerResult result,
      String type,
      String filePrefix,
      String contentType,
      Authenticated authState,
      BuildContext context,
      ) async {
    // Jika user memilih file tapi path file null (kasus langka)
    if (result.files.single.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat mengakses file yang dipilih')),
      );
      _resetFileState(type);
      return;
    }

    final file = File(result.files.single.path!);

    // Determine content type based on file extension
    contentType = _getContentTypeFromFileName(file.path, type);

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '$filePrefix/${widget.ujian.nama}-$timestamp${_extension(file.path)}';

    // Upload file menggunakan CloudflareBloc yang khusus untuk screen ini
    context.read<CloudflareBloc>().add(
      UploadFile(
        fileName: fileName,
        fileContent: file, // Gunakan File untuk mobile
        contentType: contentType,
        token: authState.token,
      ),
    );
  }

  // Helper function untuk menentukan content type berdasarkan nama file
  String _getContentTypeFromFileName(String fileName, String type) {
    final lowerFileName = fileName.toLowerCase();

    if (lowerFileName.endsWith('.png')) {
      return 'image/png';
    } else if (lowerFileName.endsWith('.jpg') || lowerFileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lowerFileName.endsWith('.gif')) {
      return 'image/gif';
    } else if (lowerFileName.endsWith('.mov')) {
      return 'video/quicktime';
    } else if (lowerFileName.endsWith('.avi')) {
      return 'video/x-msvideo';
    } else if (lowerFileName.endsWith('.mp3')) {
      return 'audio/mpeg';
    } else if (lowerFileName.endsWith('.wav')) {
      return 'audio/wav';
    } else if (lowerFileName.endsWith('.mp4')) {
      return 'video/mp4';
    } else if (lowerFileName.endsWith('.webm')) {
      return 'video/webm';
    } else if (lowerFileName.endsWith('.pdf')) {
      return 'application/pdf';
    }

    // Default content type berdasarkan tipe
    switch (type) {
      case 'gambar':
        return 'image/jpeg';
      case 'video':
        return 'video/mp4';
      case 'audio':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }

  // Helper function untuk mendapatkan extension file di web
  String _getWebFileExtension(String fileName, String type) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex).toLowerCase();
    }

    // Default extension berdasarkan tipe jika tidak ada extension
    switch (type) {
      case 'gambar':
        return '.jpg';
      case 'video':
        return '.mp4';
      case 'audio':
        return '.mp3';
      default:
        return '.bin';
    }
  }

  // Helper function untuk set state uploading
  void _setUploadingState(String type, bool isUploading) {
    setState(() {
      if (type == 'gambar') _imagePath = isUploading ? 'Uploading...' : _imagePath;
      if (type == 'video') _videoPath = isUploading ? 'Uploading...' : _videoPath;
      if (type == 'audio') _audioPath = isUploading ? 'Uploading...' : _audioPath;
      if (type == 'pembahasan_gambar') _imagePathPembahasan = isUploading ? 'Uploading...' : _imagePathPembahasan;
      if (type == 'pembahasan_video') _videoPathPembahasan = isUploading ? 'Uploading...' : _videoPathPembahasan;
      if (type == 'pembahasan_audio') _audioPathPembahasan = isUploading ? 'Uploading...' : _audioPathPembahasan;
    });
  }

  // Helper function untuk reset file state
  void _resetFileState(String type) {
    setState(() {
      if (type == 'gambar') _imagePath = '-';
      if (type == 'video') _videoPath = '-';
      if (type == 'audio') _audioPath = '-';
      if (type == 'pembahasan_gambar') _imagePathPembahasan = '-';
      if (type == 'pembahasan_video') _videoPathPembahasan = '-';
      if (type == 'pembahasan_audio') _audioPathPembahasan = '-';
    });
  }

  // Helper function untuk handle error
  void _handleUploadError(dynamic e, String type, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );

    // Reset uploading state on error
    _resetFileState(type);
  }

  String _extension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  void _addQuestion(AuthState state) {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soal tidak boleh kosong')),
      );
      return;
    }

    // Jika sedang mengupload, tunggu sampai selesai
    if (_imagePath == 'Uploading...' || _audioPath == 'Uploading...' || _videoPath == 'Uploading...') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tunggu sampai file selesai diupload')),
      );
      return;
    }

    if (_imagePathPembahasan == 'Uploading...' || _audioPathPembahasan == 'Uploading...' || _videoPathPembahasan == 'Uploading...') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tunggu sampai file selesai diupload')),
      );
      return;
    }

    if (_questionType == 'Pilihan Ganda' && _selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban yang benar')),
      );
      return;
    }

    final newQuestion = {
      'id_ujian': widget.ujian.id,
      'tipe': _questionType,
      'soal': _questionController.text,
      'opsi_a': _questionType == 'Pilihan Ganda' ? _optionAController.text : '-',
      'opsi_b': _questionType == 'Pilihan Ganda' ? _optionBController.text : '-',
      'opsi_c': _questionType == 'Pilihan Ganda' ? _optionCController.text : '-',
      'opsi_d': _questionType == 'Pilihan Ganda' ? _optionDController.text : '-',
      'opsi_e': _questionType == 'Pilihan Ganda' ? _optionEController.text : '-',
      'jawaban': _questionType == 'Pilihan Ganda' ? _selectedAnswer : '-',
      'pembahasan': _explanationController.text,
      'link_video': _videoPath != null ? 'https://edukasiin.animein.net/$_videoPath' : '-',
      'link_gambar': _imagePath != null ? 'https://edukasiin.animein.net/$_imagePath' : '-',
      'link_audio': _audioPath != null ? 'https://edukasiin.animein.net/$_audioPath' : '-',
      'link_video_pembahasan': _videoPathPembahasan != null ? 'https://edukasiin.animein.net/$_videoPathPembahasan' : '-',
      'link_gambar_pembahasan': _imagePathPembahasan != null ? 'https://edukasiin.animein.net/$_imagePathPembahasan' : '-',
      'link_audio_pembahasan': _audioPathPembahasan != null ? 'https://edukasiin.animein.net/$_audioPathPembahasan' : '-',
    };

    if(state is Authenticated){
      context.read<SoalUjianBloc>().add(AddSoal(token: state.token, soalData: newQuestion));
    }

    setState(() {
      _clearForm();
    });
  }

  // Modifikasi _clearForm untuk reset path file
  void _clearForm() {
    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    _optionEController.clear();
    _explanationController.clear();
    _mathNotationController.clear();
    _selectedAnswer = null;
    _imagePath = null;
    _audioPath = null;
    _videoPath = null;
    _imagePathPembahasan = null;
    _audioPathPembahasan = null;
    _videoPathPembahasan = null;
  }

  // Tambahkan method untuk generate AI soal
  void _generateAISoal(AuthState state) {
    if (_subjectController.text.isEmpty ||
        _topicController.text.isEmpty ||
        _gradeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mata pelajaran, topik, dan kelas harus diisi')),
      );
      return;
    }

    if (state is Authenticated) {
      context.read<SoalUjianBloc>().add(GenerateAISoal(
        token: state.token,
        subject: _subjectController.text,
        topic: _topicController.text,
        grade: _gradeController.text,
        description: _descriptionController.text,
        questionType: _aiQuestionType, // Tambahkan parameter questionType
      ));
    }
  }

  // Tambahkan widget untuk AI generator
  Widget _buildAIGenerator() {
    final authState = context.read<AuthBloc>().state;
    final soalState = context.read<SoalUjianBloc>().state;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Generate Soal dengan AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                if(soalState is! SoalUjianAILoaded)...[
                  IconButton(
                    icon: Icon(_showAIGenerator ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _showAIGenerator = !_showAIGenerator;
                      });
                    },
                  ),
                ],
              ],
            ),
            if (_showAIGenerator) ...[
              const SizedBox(height: 16),
              // Tambahkan pilihan tipe soal
              const Text('Tipe Soal:'),
              _buildAIQuestionTypeSelector(),
              const SizedBox(height: 16),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Tambahkan ini
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topik',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gradeController.text.isNotEmpty ? _gradeController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
                items: ['7', '8', '9']
                    .map((tipe) => DropdownMenuItem(
                  value: tipe,
                  child: Text(tipe),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gradeController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kelas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _generateAISoal(authState),
                  child: const Text('Generate Soal AI'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

// Modifikasi _buildAIQuestionTypeSelector
  Widget _buildAIQuestionTypeSelector() {
    // Jika bukan campuran, hanya tampilkan satu radio button yang sesuai
    if (widget.ujian.tipe_soal != 'Campuran') {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          runSpacing: 8,
          children: [
            RadioListTile<String>(
              title: Text(widget.ujian.tipe_soal),
              value: widget.ujian.tipe_soal,
              groupValue: _aiQuestionType,
              onChanged: (value) => _updateAIQuestionType(value!),
            ),
          ],
        ),
      );
    }

    // Jika campuran, tampilkan semua pilihan
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runSpacing: 8,
        children: [
          RadioListTile<String>(
            title: const Text('Pilihan Ganda'),
            value: 'Pilihan Ganda',
            groupValue: _aiQuestionType,
            onChanged: (value) => _updateAIQuestionType(value!),
          ),
          RadioListTile<String>(
            title: const Text('Isian'),
            value: 'Isian',
            groupValue: _aiQuestionType,
            onChanged: (value) => _updateAIQuestionType(value!),
          ),
          RadioListTile<String>(
            title: const Text('Upload Foto'),
            value: 'Upload Foto',
            groupValue: _aiQuestionType,
            onChanged: (value) => _updateAIQuestionType(value!),
          ),
        ],
      ),
    );
  }

  void _updateAIQuestionType(String value) {
    setState(() {
      _aiQuestionType = value;
    });
  }

  // Tambahkan widget untuk menampilkan soal AI
  Widget _buildAISoalCard(SoalModel aiSoal, AuthState authState) {
    // State untuk menandai apakah soal sudah ditambahkan
    bool isAdded = false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              aiSoal.soal,
              style: const TextStyle(fontSize: 16),
            ),

            // Hanya tampilkan pilihan jawaban jika tipe soal adalah Pilihan Ganda
            if (aiSoal.tipe == 'Pilihan Ganda') ...[
              const SizedBox(height: 12),
              _buildOptionPreview('A', aiSoal.opsiA),
              _buildOptionPreview('B', aiSoal.opsiB),
              _buildOptionPreview('C', aiSoal.opsiC),
              _buildOptionPreview('D', aiSoal.opsiD),
              _buildOptionPreview('E', aiSoal.opsiE),
              const SizedBox(height: 8),
              Text(
                'Jawaban: ${aiSoal.jawaban}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],

            const SizedBox(height: 8),
            Text('Pembahasan: ${aiSoal.pembahasan}'),
            const SizedBox(height: 16),

            if (authState is Authenticated)
              Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return ElevatedButton(
                      onPressed: isAdded
                          ? null
                          : () {
                        // Set the exam ID and type before adding
                        final soalWithExamId = aiSoal.copyWith(
                          idUjian: widget.ujian.id,
                          tipe: _aiQuestionType, // Gunakan tipe soal yang dipilih
                        );

                        context.read<SoalUjianBloc>().add(SelectAISoal(
                          token: authState.token,
                          selectedSoal: soalWithExamId,
                        ));

                        // Update state untuk menonaktifkan tombol
                        setState(() {
                          isAdded = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Soal berhasil ditambahkan'),
                            duration: Duration(seconds: 1), // Atur durasi di sini
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdded ? Colors.grey : null,
                        foregroundColor: isAdded ? Colors.white : null,
                      ),
                      child: Text(
                        isAdded ? 'Sudah Ditambahkan' : 'Tambahkan Soal Ini',
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
    final authState = context.read<AuthBloc>().state;
    return BlocListener<CloudflareBloc, CloudflareState>(
        listener: (context, state) {
          if (state is CloudFlareLoaded) {
            // Determine which file type was uploaded based on the path
            if (state.fileName.contains('Soal/Gambar')) {
              setState(() {
                _imagePath = state.fileName;
              });
            } else if (state.fileName.contains('Soal/Audio')) {
              setState(() {
                _audioPath = state.fileName;
              });
            } else if (state.fileName.contains('Soal/Video')) {
              setState(() {
                _videoPath = state.fileName;
              });
            }

            if (state.fileName.contains('Pembahasan/Gambar')) {
              setState(() {
                _imagePathPembahasan = state.fileName;
              });
            } else if (state.fileName.contains('Pembahasan/Audio')) {
              setState(() {
                _audioPathPembahasan = state.fileName;
              });
            } else if (state.fileName.contains('Pembahasan/Video')) {
              setState(() {
                _videoPathPembahasan = state.fileName;
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File berhasil diupload')),
            );
          } else if (state is CloudFlareError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal upload file: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Buat Soal untuk ${widget.ujian.nama}'),
          ),
          body: SafeArea(
              child: BlocBuilder<SoalUjianBloc, SoalUjianState>(
                  builder: (context, soalState){
                    if (authState is Authenticated && soalState is SoalUjianInitial) {
                      context.read<SoalUjianBloc>().add(FetchSoalUjian2(token: authState.token, ujianId: widget.ujian.id));
                    }

                    if(soalState is SoalUjianLoaded){
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAIGenerator(), // Tambahkan ini
                            const SizedBox(height: 16),
                            // Question Form Card
                            _buildQuestionForm(authState),
                            const SizedBox(height: 16),
                            // List of Added Questions
                            if (soalState.soalList.isNotEmpty) _buildQuestionList(soalState.soalList, authState),
                          ],
                        ),
                      );
                    }
                    else if(soalState is SoalUjianNotFound){
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAIGenerator(), // Tambahkan ini
                            const SizedBox(height: 16),
                            // Question Form Card
                            _buildQuestionForm(authState),
                            const SizedBox(height: 16),
                            Center(child: Text("Belum ada soal yang tersedia"))
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
                    else if (soalState is SoalUjianAILoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (soalState is SoalUjianAILoaded) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildAIGenerator(),
                            const SizedBox(height: 16),
                            Text(
                              'Pilih Soal yang Ingin Ditambahkan (${soalState.aiSoalList.length} soal dihasilkan)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            ...soalState.aiSoalList.map((aiSoal) => _buildAISoalCard(aiSoal, authState)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SoalUjianBloc>().add(ClearAISoal());
                              },
                              child: const Text('Kembali ke Buat Soal Manual'),
                            ),
                          ],
                        ),
                      );
                    } else if (soalState is SoalUjianAIError) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildAIGenerator(),
                            const SizedBox(height: 16),
                            Center(child: Text('Error: ${soalState.message}')),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SoalUjianBloc>().add(ClearAISoal());
                              },
                              child: const Text('Kembali'),
                            ),
                          ],
                        ),
                      );
                    }
                    else {
                      return const Center(child: Text(""));
                    }
                  }
              )
          ),
        )
    );
  }

  Widget _buildQuestionForm(AuthState authState) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Soal Baru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            // Question Type Selection
            const Text('Jenis Soal:'),
            _buildQuestionTypeSelector(),
            const SizedBox(height: 16),
            // Media Attachment Buttons
            const Text('Lampiran Media:'),
            const SizedBox(height: 8),
            _buildMediaButtons(),
            const SizedBox(height: 8),
            // Tampilkan preview jika file sudah diupload
            _buildMediaGridSoal(),
            const SizedBox(height: 16),
            // Question Input
            TextField(
              controller: _questionController,
              focusNode: _questionFocusNode,
              decoration: const InputDecoration(
                labelText: 'Tulis soal disini',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            // Math notation untuk question
            if (_showMathNotations) ...[
              const SizedBox(height: 8),
              MathNotationWidget(
                targetController: _questionController,
                targetFocusNode: _questionFocusNode,
              ),
            ],
            const SizedBox(height: 16),
            // Options for Multiple Choice
            if (_questionType == 'Pilihan Ganda') _buildMultipleChoiceOptions(),
            // Explanation Field
            const Text('Lampiran Media Pembahasan:'),
            const SizedBox(height: 8),
            _buildMediaButtonsPembahasan(),
            const SizedBox(height: 8),
            // Tampilkan preview jika file sudah diupload
            _buildMediaGridPembahasan(),
            _buildExplanationField(),
            // Math notation untuk question
            if (_showMathNotations) ...[
              const SizedBox(height: 8),
              MathNotationWidget(
                targetController: _explanationController,
                targetFocusNode: _explanationFocusNode,
              ),
            ],
            const SizedBox(height: 16),
            // Add Question Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _addQuestion(authState);
                },
                child: const Text('Tambah Soal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modifikasi _buildQuestionTypeSelector
  Widget _buildQuestionTypeSelector() {
    // Jika bukan campuran, hanya tampilkan satu radio button yang sesuai
    if (widget.ujian.tipe_soal != 'Campuran') {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          runSpacing: 8,
          children: [
            RadioListTile<String>(
              title: Text(widget.ujian.tipe_soal),
              value: widget.ujian.tipe_soal,
              groupValue: _questionType,
              onChanged: (value) => _updateQuestionType(value!),
            ),
          ],
        ),
      );
    }

    // Jika campuran, tampilkan semua pilihan
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runSpacing: 8,
        children: [
          RadioListTile<String>(
            title: const Text('Pilihan Ganda'),
            value: 'Pilihan Ganda',
            groupValue: _questionType,
            onChanged: (value) => _updateQuestionType(value!),
          ),
          RadioListTile<String>(
            title: const Text('Isian'),
            value: 'Isian',
            groupValue: _questionType,
            onChanged: (value) => _updateQuestionType(value!),
          ),
          RadioListTile<String>(
            title: const Text('Upload Foto'),
            value: 'Upload Foto',
            groupValue: _questionType,
            onChanged: (value) => _updateQuestionType(value!),
          ),
        ],
      ),
    );
  }

  void _updateQuestionType(String value) {
    setState(() {
      _questionType = value;
      _selectedAnswer = null;
    });
  }

  // Modifikasi _buildMediaButtons untuk menambahkan fungsi upload
  Widget _buildMediaButtons() {
    return Wrap(
      spacing: 8,
      children: [
        IconButton(
          icon: const Icon(Icons.image),
          color: _imagePath != null && _imagePath != '-' ? Colors.blue : null,
          onPressed: () => _pickFile('gambar', context),
        ),
        IconButton(
          icon: const Icon(Icons.audiotrack),
          color: _audioPath != null && _audioPath != '-'? Colors.blue : null,
          onPressed: () => _pickFile('audio', context),
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: _videoPath != null && _videoPath != '-'? Colors.blue : null,
          onPressed: () => _pickFile('video', context),
        ),
        IconButton(
          icon: const Icon(Icons.functions),
          color: _mathNotationController.text.isNotEmpty ? Colors.blue : null,
          onPressed: (){
            setState(() {
              _showMathNotations = !_showMathNotations;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMediaButtonsPembahasan() {
    return Wrap(
      spacing: 8,
      children: [
        IconButton(
          icon: const Icon(Icons.image),
          color: _imagePathPembahasan != null && _imagePathPembahasan != '-' ? Colors.blue : null,
          onPressed: () => _pickFile('pembahasan_gambar', context),
        ),
        IconButton(
          icon: const Icon(Icons.audiotrack),
          color: _audioPathPembahasan != null && _audioPathPembahasan != '-'? Colors.blue : null,
          onPressed: () => _pickFile('pembahasan_audio', context),
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: _videoPathPembahasan != null && _videoPathPembahasan != '-'? Colors.blue : null,
          onPressed: () => _pickFile('pembahasan_video', context),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilihan Jawaban:'),
        const SizedBox(height: 8),
        _buildOptionField('A', _optionAController),
        if (_showMathNotations) ...[
          const SizedBox(height: 8),
          MathNotationWidget(
            targetController: _optionAController,
            targetFocusNode: _optionAFocusNode,
          ),
        ],
        _buildOptionField('B', _optionBController),
        if (_showMathNotations) ...[
          const SizedBox(height: 8),
          MathNotationWidget(
            targetController: _optionBController,
            targetFocusNode: _optionBFocusNode,
          ),
        ],
        _buildOptionField('C', _optionCController),
        if (_showMathNotations) ...[
          const SizedBox(height: 8),
          MathNotationWidget(
            targetController: _optionCController,
            targetFocusNode: _optionCFocusNode,
          ),
        ],
        _buildOptionField('D', _optionDController),
        if (_showMathNotations) ...[
          const SizedBox(height: 8),
          MathNotationWidget(
            targetController: _optionDController,
            targetFocusNode: _optionDFocusNode,
          ),
        ],
        _buildOptionField('E', _optionEController),
        if (_showMathNotations) ...[
          const SizedBox(height: 8),
          MathNotationWidget(
            targetController: _optionEController,
            targetFocusNode: _optionEFocusNode,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Pilih Jawaban yang Benar:'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['A', 'B', 'C', 'D', 'E'].map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(option),
                  selected: _selectedAnswer == option,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAnswer = selected ? option : null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExplanationField() {
    return TextField(
      controller: _explanationController,
      decoration: const InputDecoration(
        labelText: 'Pembahasan (mengapa jawaban benar)',
        border: OutlineInputBorder(),
      ),
      maxLines: 10,
    );
  }

  Widget _buildQuestionList(List<SoalModel> soal, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Soal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        if(authState is Authenticated)
          ...soal.map((question) => _buildQuestionCard(question, soal, authState.token)),
      ],
    );
  }

  Widget _buildOptionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Opsi $label',
          border: const OutlineInputBorder(),
          prefixText: '$label. ',
        ),
      ),
    );
  }

  Widget _buildQuestionCard(SoalModel question, List<SoalModel> soal, String token) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Soal ${soal.indexOf(question) + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InsertSoalDanJawabanScreen(
                          soalData: question,
                          isEdit: true,
                          idUjian: widget.ujian.id,
                        ),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        final index = soal.indexWhere((s) => s.id == question.id);
                        if (index != -1) {
                          soal[index] = result;
                        }
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    context.read<SoalUjianBloc>().add(DeleteSoal(token: token, id: question.id, id_ujian: widget.ujian.id));
                    setState(() {
                      soal.remove(question);
                    });
                  },
                ),
              ],
            ),
            // Tampilkan preview media
            _buildMediaGrid(question),
            const SizedBox(height: 8),
            Text(question.soal),
            if (question.tipe == 'Pilihan Ganda') ...[
              const SizedBox(height: 8),
              const Text('Pilihan Jawaban:'),
              _buildOptionPreview('A', question.opsiA),
              _buildOptionPreview('B', question.opsiB),
              _buildOptionPreview('C', question.opsiC),
              _buildOptionPreview('D', question.opsiD),
              _buildOptionPreview('E', question.opsiE),
              const SizedBox(height: 8),
              Text(
                'Jawaban benar: ${question.jawaban}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            ...[
              const SizedBox(height: 8),
              const Text('Pembahasan:'),
              if(question.linkGambarPembahasan != '-' || question.linkVideoPembahasan != '-' || question.linkAudioPembahasan != '-')
                const SizedBox(height: 8),
              _buildMediaGridPembahasanSoal(question),
              const SizedBox(height: 8),
              Text(question.pembahasan),
              if (_imagePath == 'Uploading...' || _audioPath == 'Uploading...' || _videoPath == 'Uploading...')
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Mengupload file...'),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionPreview(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label. $value'),
    );
  }
}

