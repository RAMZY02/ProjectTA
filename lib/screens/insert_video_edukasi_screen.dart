import 'package:flutter/material.dart';

class InsertVideoEdukasiScreen extends StatefulWidget {
  final Map<String, dynamic>? videoData;

  bool get isEdit => videoData != null;

  const InsertVideoEdukasiScreen({
    super.key,
    this.videoData,
  });

  @override
  State<InsertVideoEdukasiScreen> createState() => _InsertVideoEdukasiScreenState();
}

class _InsertVideoEdukasiScreenState extends State<InsertVideoEdukasiScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _linkController;
  late TextEditingController _deskripsiController;
  late TextEditingController _mataPelajaranController;
  late TextEditingController _viewsController;
  late TextEditingController _likesController;
  late String _selectedKelas;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.videoData?['judul'] ?? '');
    _linkController = TextEditingController(text: widget.videoData?['link_video'] ?? '');
    _deskripsiController = TextEditingController(text: widget.videoData?['deskripsi'] ?? '');
    _mataPelajaranController = TextEditingController(text: widget.videoData?['mata_pelajaran'] ?? '');
    _viewsController = TextEditingController(text: widget.videoData?['views']?.toString() ?? '0');
    _likesController = TextEditingController(text: widget.videoData?['likes']?.toString() ?? '0');
    _selectedKelas = widget.videoData?['kelas'] ?? '7';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _linkController.dispose();
    _deskripsiController.dispose();
    _mataPelajaranController.dispose();
    _viewsController.dispose();
    _likesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final videoData = {
        'id': widget.isEdit ? widget.videoData!['id'] : null,
        'judul': _judulController.text,
        'link_video': _linkController.text,
        'deskripsi': _deskripsiController.text,
        'mata_pelajaran': _mataPelajaranController.text,
        'views': int.parse(_viewsController.text),
        'likes': int.parse(_likesController.text),
        'kelas': _selectedKelas,
      };

      Navigator.pop(context, videoData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Video Edukasi' : 'Tambah Video Edukasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Video',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link Video',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Link video tidak boleh kosong';
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath) {
                    return 'Masukkan link yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mataPelajaranController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mata pelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
                items: ['7', '8', '9']
                    .map((kelas) => DropdownMenuItem(
                  value: kelas,
                  child: Text('Kelas $kelas'),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKelas = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _viewsController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Views',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah views tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _likesController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Likes',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah likes tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Video',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(widget.isEdit ? 'Update Video' : 'Simpan Video'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}