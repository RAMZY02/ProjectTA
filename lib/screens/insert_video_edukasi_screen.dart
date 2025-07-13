import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/models/video_edukasi_model.dart';

class InsertVideoEdukasiScreen extends StatefulWidget {
  final VideoEdukasiModel? videoData;

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
  late TextEditingController _durasiController;
  late String _selectedKelas;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.videoData?.judul ?? '');
    _linkController = TextEditingController(text: widget.videoData?.link_video ?? '');
    _deskripsiController = TextEditingController(text: widget.videoData?.deskripsi ?? '');
    _mataPelajaranController = TextEditingController(text: widget.videoData?.mata_pelajaran ?? '');
    _viewsController = TextEditingController(text: widget.videoData?.views.toString() ?? '0');
    _likesController = TextEditingController(text: widget.videoData?.likes.toString() ?? '0');
    _durasiController = TextEditingController(text: widget.videoData?.durasi.toString() ?? '00:00:00');
    _selectedKelas = widget.videoData?.kelas ?? '7';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _linkController.dispose();
    _deskripsiController.dispose();
    _mataPelajaranController.dispose();
    _viewsController.dispose();
    _likesController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  void _submitForm(AuthState state) async{
    if (_formKey.currentState!.validate()) {
      final videoData = {
        'judul': _judulController.text,
        'link_video': _linkController.text,
        'deskripsi': _deskripsiController.text,
        'mata_pelajaran': _mataPelajaranController.text,
        'views': int.parse(_viewsController.text),
        'likes': int.parse(_likesController.text),
        'kelas': _selectedKelas,
        'durasi': _durasiController.text,
      };

      if (!widget.isEdit) {
        if (state is Authenticated) {
          print("masuk sini kah");
          context.read<VideoEdukasiBloc>().add(AddVideo(token: state.token, idUser: state.id, videoEdukasi: videoData));
        }
      } else {
        if (state is Authenticated) {
          context.read<VideoEdukasiBloc>().add(UpdateVideo(token: state.token, idUser: state.id, idVideo: widget.videoData!.id, videoEdukasi: videoData));
        }
      }

      Navigator.pop(context, videoData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
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
                controller: _durasiController,
                decoration: const InputDecoration(
                  labelText: 'Durasi (HH:MM:SS)',
                  border: OutlineInputBorder(),
                  hintText: '00:05:30',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Durasi tidak boleh kosong';
                  }
                  // Basic validation for HH:MM:SS format
                  if (!RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(value)) {
                    return 'Format durasi harus HH:MM:SS';
                  }
                  return null;
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _submitForm(authState);
                },
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