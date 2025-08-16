import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_bloc.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_state.dart';
import 'package:project_ta/models/video_edukasi_model.dart';

import '../bloc/cloudflare/cloudflare_state.dart';

class InsertVideoEdukasiScreen extends StatefulWidget {
  final VideoEdukasiModel? videoData;

  bool get isEdit => videoData != null;

  const InsertVideoEdukasiScreen({
    super.key,
    this.videoData
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
  late String _selectedKelas;
  
  bool _isUploading = false;
  String? _uploadError;
  String? _uploadSuccess;
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.videoData?.judul ?? '');
    _linkController = TextEditingController(
      text: widget.videoData?.link_video ?? '',
    );
    _deskripsiController = TextEditingController(text: widget.videoData?.deskripsi ?? '');
    _mataPelajaranController = TextEditingController(text: widget.videoData?.mata_pelajaran ?? '');
    _selectedKelas = widget.videoData?.kelas ?? '7';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _linkController.dispose();
    _deskripsiController.dispose();
    _mataPelajaranController.dispose();
    super.dispose();
  }

  Future<void> _selectVideo(AuthState state) async {
    if (state is! Authenticated) return;
    context.read<VideoEdukasiBloc>().add(LastId(token: state.token));
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _isUploading = true;
          _uploadError = null;
        });

        // Dapatkan contentType dari file
        String contentType = 'video/mp4'; // Default
        if (file.path.toLowerCase().endsWith('.mov')) {
          contentType = 'video/quicktime';
        } else if (file.path.toLowerCase().endsWith('.avi')) {
          contentType = 'video/x-msvideo';
        }

        final videoState = context.read<VideoEdukasiBloc>().state;

        if(videoState is VideoId){
          context.read<CloudflareBloc>().add(
            UploadFile(
              fileName: 'VideoEdukasi/${_mataPelajaranController.text}-${_judulController.text}-Kelas $_selectedKelas-${videoState.IdVideo + 1}${extension(file.path)}',
              fileContent: file,
              contentType: contentType,
              token: state.token,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Gagal memilih video: ${e.toString()}';
      });
    }
  }

  String extension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      // Validasi video sudah diupload
      if (_linkController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap upload video terlebih dahulu!')),
        );
        return;
      }

      // Hanya kirim data yang bisa di-serialize
      final videoData = {
        'judul': _judulController.text,
        'link_video': _linkController.text, // Pastikan ini string URL
        'deskripsi': _deskripsiController.text,
        'mata_pelajaran': _mataPelajaranController.text,
        'kelas': _selectedKelas,
        'views': 0,
        'likes': 0,
        'durasi': "00:00:00",
      };

      if (state is Authenticated) {
        if (!widget.isEdit) {
          context.read<VideoEdukasiBloc>().add(
            AddVideo(
              token: state.token,
              idUser: state.id,
              videoEdukasi: videoData,
            ),
          );
        } else {
          context.read<VideoEdukasiBloc>().add(
            UpdateVideo(
              token: state.token,
              idUser: state.id,
              idVideo: widget.videoData!.id,
              videoEdukasi: videoData,
            ),
          );
        }
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Video Edukasi' : 'Tambah Video Edukasi'),
      ),
      body: BlocListener<CloudflareBloc, CloudflareState>(
        listener: (context, state) {
          if (state is CloudFlareLoading) {
            setState(() => _isUploading = true);
          }
          else if (state is CloudFlareLoaded) {
            setState(() {
              _isUploading = false;
              // Format URL sesuai dengan bucket Anda
              _linkController.text = 'https://edukasiin.animein.net/${state.fileName}';
            });
          }
          else if (state is CloudFlareError) {
            setState(() {
              _isUploading = false;
              _uploadError = state.message;
            });
          }
        },
        child: SingleChildScrollView(
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
                  controller: _linkController,
                  decoration: InputDecoration(
                    labelText: 'Link Video',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Link video tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_isUploading)
                  Column(
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text('Uploading...'),
                    ],
                  ),
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () {
                    if (_judulController.text.isEmpty || _mataPelajaranController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Harap isi judul dan mata pelajaran terlebih dahulu'),
                        ),
                      );
                      return;
                    }
                    _selectVideo(authState);
                  },
                  child: const Text('Select Video'),
                ),
                if (_uploadError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _uploadError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_uploadSuccess != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _uploadSuccess!,
                      style: const TextStyle(color: Colors.green),
                    ),
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
                  onPressed: () => _submitForm(authState),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.isEdit ? 'Update Video' : 'Simpan Video'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}