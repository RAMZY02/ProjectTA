import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class InsertSoalDanJawabanScreen extends StatefulWidget {
  final Map<String, dynamic>? soalData;
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
  int lastUsedId = 0; // Inisialisasi dengan 0 atau nilai terakhir dari database

  File? _gambarFile;
  File? _videoFile;
  File? _audioFile;
  File? _docFile;
  String? _gambarPath;
  String? _videoPath;
  String? _audioPath;
  String? _docPath;

  final List<String> _tipeSoalOptions = ['Pilihan Ganda', 'Isian', 'Upload File'];
  final List<String> _jawabanOptions = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _soalController = TextEditingController(text: widget.soalData?['soal'] ?? '');
    _opsi1Controller = TextEditingController(text: widget.soalData?['opsi1'] ?? '');
    _opsi2Controller = TextEditingController(text: widget.soalData?['opsi2'] ?? '');
    _opsi3Controller = TextEditingController(text: widget.soalData?['opsi3'] ?? '');
    _opsi4Controller = TextEditingController(text: widget.soalData?['opsi4'] ?? '');
    _opsi5Controller = TextEditingController(text: widget.soalData?['opsi5'] ?? '');
    _jawabanController = TextEditingController(text: widget.soalData?['jawaban'] ?? '');
    _pembahasanController = TextEditingController(text: widget.soalData?['pembahasan'] ?? '');

    _selectedTipe = widget.soalData?['tipe'] ?? 'Pilihan Ganda';
    _selectedJawaban = widget.soalData?['jawaban'] != null
        ? _getJawabanOption(widget.soalData?['jawaban'])
        : null;

    // Initialize file paths from existing data
    _gambarPath = widget.soalData?['link_gambar'] ?? '-';
    _videoPath = widget.soalData?['link_video'] ?? '-';
    _audioPath = widget.soalData?['link_audio'] ?? '-';
    _docPath = widget.soalData?['link_file'] ?? '-';
  }

  String? _getJawabanOption(String? jawaban) {
    if (jawaban == _opsi1Controller.text) return 'A';
    if (jawaban == _opsi2Controller.text) return 'B';
    if (jawaban == _opsi3Controller.text) return 'C';
    if (jawaban == _opsi4Controller.text) return 'D';
    if (jawaban == _opsi5Controller.text) return 'E';
    return null;
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

  Future<void> _pickFile(String type) async {
    try {
      if (type == 'gambar') {
        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (file != null) {
          setState(() {
            _gambarFile = File(file.path);
            _gambarPath = file.path;
          });
        }
      } else if (type == 'video') {
        final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
        if (file != null) {
          setState(() {
            _videoFile = File(file.path);
            _videoPath = file.path;
          });
        }
      } else if (type == 'audio' || type == 'doc') {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          final file = File(result.files.single.path!);
          setState(() {
            if (type == 'audio') {
              _audioFile = file;
              _audioPath = file.path;
            } else {
              _docFile = file;
              _docPath = file.path;
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Soal' : 'Tambah Soal'),
      ),
      body: SingleChildScrollView(
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
              ] else ...[
                // Jawaban Field for other types
                TextFormField(
                  controller: _jawabanController,
                  decoration: const InputDecoration(
                    labelText: 'Jawaban',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan jawaban',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jawaban tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

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
                  _buildMediaButton('Gambar', Icons.image, () => _pickFile('gambar')),
                  _buildMediaButton('Video', Icons.videocam, () => _pickFile('video')),
                  _buildMediaButton('Audio', Icons.audiotrack, () => _pickFile('audio')),
                  _buildMediaButton('Dokumen', Icons.insert_drive_file, () => _pickFile('doc')),
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
                  onPressed: _submitForm,
                  child: Text(widget.isEdit ? 'Update Soal' : 'Simpan Soal'),
                ),
              ),
            ],
          ),
        ),
      ),
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
        if (_selectedJawaban != null) {
          setState(() {});
        }
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
            label: Text(_gambarPath!.split('/').last),
            avatar: const Icon(Icons.image, size: 20),
            onDeleted: () => setState(() {
              _gambarFile = null;
              _gambarPath = '-';
            }),
          ),
        if (_videoPath != null && _videoPath != '-')
          Chip(
            label: Text(_videoPath!.split('/').last),
            avatar: const Icon(Icons.videocam, size: 20),
            onDeleted: () => setState(() {
              _videoFile = null;
              _videoPath = '-';
            }),
          ),
        if (_audioPath != null && _audioPath != '-')
          Chip(
            label: Text(_audioPath!.split('/').last),
            avatar: const Icon(Icons.audiotrack, size: 20),
            onDeleted: () => setState(() {
              _audioFile = null;
              _audioPath = '-';
            }),
          ),
        if (_docPath != null && _docPath != '-')
          Chip(
            label: Text(_docPath!.split('/').last),
            avatar: const Icon(Icons.insert_drive_file, size: 20),
            onDeleted: () => setState(() {
              _docFile = null;
              _docPath = '-';
            }),
          ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final jawaban = _selectedTipe == 'Pilihan Ganda'
          ? _getJawabanText(_selectedJawaban!)
          : _jawabanController.text;

      final soalData = {
        'id': widget.soalData?['id'] != null
            ? (widget.soalData!['id'] + 1).toString()
            : (lastUsedId + 1).toString(),
        'id_ujian': widget.idUjian ?? widget.soalData?['id_ujian'],
        'soal': _soalController.text,
        'opsi1': _selectedTipe == 'Pilihan Ganda' ? _opsi1Controller.text : '-',
        'opsi2': _selectedTipe == 'Pilihan Ganda' ? _opsi2Controller.text : '-',
        'opsi3': _selectedTipe == 'Pilihan Ganda' ? _opsi3Controller.text : '-',
        'opsi4': _selectedTipe == 'Pilihan Ganda' ? _opsi4Controller.text : '-',
        'opsi5': _selectedTipe == 'Pilihan Ganda' ? _opsi5Controller.text : '-',
        'jawaban': jawaban,
        'tipe': _selectedTipe,
        'pembahasan': _pembahasanController.text,
        'link_video': _videoPath ?? '-',
        'link_gambar': _gambarPath ?? '-',
        'link_audio': _audioPath ?? '-',
        'link_file': _docPath ?? '-',
      };

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