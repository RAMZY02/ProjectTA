import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'dart:io';

import 'package:project_ta/models/soal_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';

class InsertSoalDanJawabanScreen extends StatefulWidget {
  final SoalModel? soalData;
  final bool isEdit;
  final int? idUjian;

  const InsertSoalDanJawabanScreen({
    super.key,
    this.soalData,
    this.isEdit = false,
    this.idUjian,
  });

  @override
  State<InsertSoalDanJawabanScreen> createState() => _InsertSoalDanJawabanScreenState();
}

class _InsertSoalDanJawabanScreenState extends State<InsertSoalDanJawabanScreen> {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _soalController;
  late TextEditingController _opsi1Controller;
  late TextEditingController _opsi2Controller;
  late TextEditingController _opsi3Controller;
  late TextEditingController _opsi4Controller;
  late TextEditingController _opsi5Controller;
  late TextEditingController _jawabanController;
  late TextEditingController _pembahasanController;

  String _selectedTipe = 'Pilihan Ganda';
  String? _selectedJawaban;

  String? _gambarPath;
  String? _videoPath;
  String? _audioPath;
  String? _docPath;

  final List<String> _tipeSoalOptions = ['Pilihan Ganda', 'Isian', 'Upload Foto'];
  final List<String> _jawabanOptions = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _soalController = TextEditingController(text: widget.soalData?.soal ?? '');
    _opsi1Controller = TextEditingController(text: widget.soalData?.opsiA ?? '');
    _opsi2Controller = TextEditingController(text: widget.soalData?.opsiB ?? '');
    _opsi3Controller = TextEditingController(text: widget.soalData?.opsiC ?? '');
    _opsi4Controller = TextEditingController(text: widget.soalData?.opsiD ?? '');
    _opsi5Controller = TextEditingController(text: widget.soalData?.opsiE ?? '');
    _jawabanController = TextEditingController(text: widget.soalData?.jawaban ?? '');
    _pembahasanController = TextEditingController(text: widget.soalData?.pembahasan ?? '');

    _selectedTipe = widget.soalData?.tipe ?? 'Pilihan Ganda';
    _selectedJawaban = widget.soalData?.jawaban != null
        ? widget.soalData!.jawaban
        : null;

    // Initialize file paths from existing data
    _gambarPath = widget.soalData?.linkGambar ?? '-';
    _videoPath = widget.soalData?.linkVideo ?? '-';
    _audioPath = widget.soalData?.linkAudio ?? '-';
  }

  String _getJawabanText(String option) {
    switch (option) {
      case 'A': return _opsi1Controller.text;
      case 'B': return _opsi2Controller.text;
      case 'C': return _opsi3Controller.text;
      case 'D': return _opsi4Controller.text;
      case 'E': return _opsi5Controller.text;
      default: return '';
    }
  }

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
      final fileName = '$filePrefix/${widget.idUjian}-$timestamp$fileExtension';

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
    final fileName = '$filePrefix/${widget.idUjian}-$timestamp${extension(file.path)}';

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
      if (type == 'gambar') _gambarPath = isUploading ? 'Uploading...' : _gambarPath;
      if (type == 'video') _videoPath = isUploading ? 'Uploading...' : _videoPath;
      if (type == 'audio') _audioPath = isUploading ? 'Uploading...' : _audioPath;
    });
  }

  // Helper function untuk reset file state
  void _resetFileState(String type) {
    setState(() {
      if (type == 'gambar') _gambarPath = '-';
      if (type == 'video') _videoPath = '-';
      if (type == 'audio') _audioPath = '-';
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

  String extension(String path) {
    return path.substring(path.lastIndexOf('.'));
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
              _gambarPath = state.fileName;
            });
          } else if (state.fileName.contains('Soal/Video')) {
            setState(() {
              _videoPath = state.fileName;
            });
          } else if (state.fileName.contains('Soal/Audio')) {
            setState(() {
              _audioPath = state.fileName;
            });
          } else if (state.fileName.contains('Soal/Dokumen')) {
            setState(() {
              _docPath = state.fileName;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File berhasil diupload')),
          );
        } else if (state is CloudFlareError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload file: ${state.message}')),
          );

          // Reset the uploading state
          setState(() {
            if (_gambarPath == 'Uploading...') _gambarPath = '-';
            if (_videoPath == 'Uploading...') _videoPath = '-';
            if (_audioPath == 'Uploading...') _audioPath = '-';
            if (_docPath == 'Uploading...') _docPath = '-';
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Soal' : 'Tambah Soal'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.idUjian != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Ujian ID: ${widget.idUjian}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                  // Tipe Soal Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTipe,
                    decoration: const InputDecoration(
                      labelText: 'Tipe Soal',
                      border: OutlineInputBorder(),
                    ),
                    items: _tipeSoalOptions.map((tipe) {
                      return DropdownMenuItem(
                        value: tipe,
                        child: Text(tipe),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTipe = value!;
                        _selectedJawaban = null;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih tipe soal';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Soal Field
                  TextFormField(
                    controller: _soalController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Pertanyaan',
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan pertanyaan soal',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pertanyaan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Options Fields (only for Pilihan Ganda)
                  if (_selectedTipe == 'Pilihan Ganda') ...[
                    _buildOptionField(_opsi1Controller, 'Opsi A'),
                    const SizedBox(height: 12),
                    _buildOptionField(_opsi2Controller, 'Opsi B'),
                    const SizedBox(height: 12),
                    _buildOptionField(_opsi3Controller, 'Opsi C'),
                    const SizedBox(height: 12),
                    _buildOptionField(_opsi4Controller, 'Opsi D'),
                    const SizedBox(height: 12),
                    _buildOptionField(_opsi5Controller, 'Opsi E'),
                    const SizedBox(height: 16),

                    // Jawaban Dropdown for Pilihan Ganda
                    DropdownButtonFormField<String>(
                      value: _selectedJawaban,
                      decoration: const InputDecoration(
                        labelText: 'Jawaban Benar',
                        border: OutlineInputBorder(),
                      ),
                      items: _jawabanOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text('Opsi $option: ${_getJawabanText(option)}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJawaban = value;
                        });
                      },
                      validator: (value) {
                        if (_selectedTipe == 'Pilihan Ganda' && (value == null || value.isEmpty)) {
                          return 'Pilih jawaban yang benar';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Pembahasan Field
                  TextFormField(
                    controller: _pembahasanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Pembahasan',
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan pembahasan soal',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Media Upload Section
                  const Text('Tambahkan Media:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMediaButton('Gambar', Icons.image, () => _pickFile('gambar', context)),
                      _buildMediaButton('Video', Icons.videocam, () => _pickFile('video', context)),
                      _buildMediaButton('Audio', Icons.audiotrack, () => _pickFile('audio', context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMediaPreview(),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        _submitForm(authState, context);
                      },
                      child: Text(widget.isEdit ? 'Update Soal' : 'Simpan Soal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      )
    );
  }

  Widget _buildOptionField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        hintText: 'Masukkan $label',
      ),
      validator: (value) {
        if (_selectedTipe == 'Pilihan Ganda' && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildMediaButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildMediaPreview() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_gambarPath != null && _gambarPath != '-')
          Chip(
            label: _gambarPath == 'Uploading...'
                ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Uploading...'),
              ],
            )
                : Text(_gambarPath!.split('/').last),
            avatar: const Icon(Icons.image, size: 20),
            onDeleted: () => setState(() {
              _gambarPath = '-';
            }),
          ),
        if (_videoPath != null && _videoPath != '-')
          Chip(
            label: _videoPath == 'Uploading...'
                ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Uploading...'),
              ],
            )
                : Text(_videoPath!.split('/').last),
            avatar: const Icon(Icons.videocam, size: 20),
            onDeleted: () => setState(() {
              _videoPath = '-';
            }),
          ),
        if (_audioPath != null && _audioPath != '-')
          Chip(
            label: _audioPath == 'Uploading...'
                ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Uploading...'),
              ],
            )
                : Text(_audioPath!.split('/').last),
            avatar: const Icon(Icons.audiotrack, size: 20),
            onDeleted: () => setState(() {
              _audioPath = '-';
            }),
          ),
        if (_docPath != null && _docPath != '-')
          Chip(
            label: _docPath == 'Uploading...'
                ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Uploading...'),
              ],
            )
                : Text(_docPath!.split('/').last),
            avatar: const Icon(Icons.insert_drive_file, size: 20),
            onDeleted: () => setState(() {
              _docPath = '-';
            }),
          ),
      ],
    );
  }

  void _submitForm(AuthState state, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      print("ini tipe nya");
      print(_selectedTipe);
      print("ini jawaban controller");
      print(_jawabanController.text);
      final jawaban = _selectedTipe == 'Pilihan Ganda'
          ? _selectedJawaban
          : _jawabanController.text;

      final soalData = {
        'id' : widget.soalData?.id ?? '',
        'id_ujian': widget.idUjian ?? widget.soalData?.idUjian,
        'tipe': _selectedTipe,
        'soal': _soalController.text,
        'opsi_a': _selectedTipe == 'Pilihan Ganda' ? _opsi1Controller.text : '-',
        'opsi_b': _selectedTipe == 'Pilihan Ganda' ? _opsi2Controller.text : '-',
        'opsi_c': _selectedTipe == 'Pilihan Ganda' ? _opsi3Controller.text : '-',
        'opsi_d': _selectedTipe == 'Pilihan Ganda' ? _opsi4Controller.text : '-',
        'opsi_e': _selectedTipe == 'Pilihan Ganda' ? _opsi5Controller.text : '-',
        'jawaban': jawaban,
        'pembahasan': _pembahasanController.text,
        'link_video': _videoPath != '-' && _videoPath!.contains('https') ? _videoPath : _videoPath != '-' ? 'https://edukasiin.animein.net/$_videoPath' : '-',
        'link_gambar': _gambarPath != '-' && _gambarPath!.contains('https') ? _gambarPath : _gambarPath != '-' ? 'https://edukasiin.animein.net/$_gambarPath' : '-',
        'link_audio': _audioPath != '-' && _audioPath!.contains('https') ? _audioPath : _audioPath != '-' ? 'https://edukasiin.animein.net/$_audioPath' : '-',
      };

      if (!widget.isEdit) {
        if (state is Authenticated) {
          print("masuk sini kah");
          print(soalData);
          context.read<SoalUjianBloc>().add(AddSoal(token: state.token, soalData: soalData));
        }
      } else {
        if (state is Authenticated) {
          context.read<SoalUjianBloc>().add(UpdateSoal(token: state.token, soalData: soalData));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Soal berhasil diperbarui'
                : 'Soal berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context, soalData);
    }
  }

  @override
  void dispose() {
    _soalController.dispose();
    _opsi1Controller.dispose();
    _opsi2Controller.dispose();
    _opsi3Controller.dispose();
    _opsi4Controller.dispose();
    _opsi5Controller.dispose();
    _jawabanController.dispose();
    _pembahasanController.dispose();
    super.dispose();
  }
}