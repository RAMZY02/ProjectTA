import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/jawaban_siswa/jawaban_siswa_bloc.dart';
import '../bloc/jawaban_siswa/jawaban_siswa_event.dart';
import '../models/soal_model.dart';

class CameraScreen extends StatefulWidget {
  final SoalModel soal;
  final int questionIndex;

  const CameraScreen({Key? key, required this.soal, required this.questionIndex}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  bool _isCapturing = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![0], // Gunakan kamera belakang
      ResolutionPreset.high,
    );
    await _controller!.initialize();
    setState(() => _isLoading = false);
  }

  Future<void> _takePicture() async {
    if (_isCapturing || !_controller!.value.isInitialized) return;

    setState(() => _isCapturing = true);
    try {
      final image = await _controller!.takePicture();
      setState(() => _capturedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _uploadAndReturn() async {
    if (_capturedImage == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final imageFile = File(_capturedImage!.path);
    final contentType = lookupMimeType(_capturedImage!.path) ?? 'image/jpeg';
    final fileName = 'Jawaban/user-${authState.id}-ujian-${widget.soal.idUjian}-soal-${widget.soal.id}.jpg';

    context.read<CloudflareBloc>().add(
      UploadFile(
        token: authState.token,
        fileContent: imageFile,  // Pass the File directly
        fileName: fileName,
        contentType: contentType,
      ),
    );

    context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(token: authState.token, ujianId: widget.soal.idUjian, soalId: widget.soal.id, jawaban: 'https://edukasiin.animein.net/$fileName', nilai: 0, userId: authState.id));

    Navigator.pop(context, _capturedImage!.path);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Kamera')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ambil Foto Jawaban'),
        actions: [
          if (_capturedImage != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _uploadAndReturn,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _capturedImage != null
                ? Image.file(File(_capturedImage!.path))
                : CameraPreview(_controller!),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_capturedImage != null)
                  FloatingActionButton(
                    onPressed: _retakePicture,
                    heroTag: 'retake',
                    child: Icon(Icons.arrow_back),
                  ),
                if (_capturedImage == null)
                  FloatingActionButton(
                    onPressed: _takePicture,
                    heroTag: 'capture',
                    child: _isCapturing
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(Icons.camera_alt),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}