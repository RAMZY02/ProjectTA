import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  const CameraScreen({super.key, required this.soal, required this.questionIndex});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  bool _isCapturing = false;
  bool _isUploading = false;
  XFile? _capturedImage;
  String? _capturedImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium, // Turunkan resolusi untuk performa web
        );
        await _controller!.initialize();
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak ada kamera yang tersedia')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menginisialisasi kamera: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    if (_isCapturing || !_controller!.value.isInitialized) return;

    setState(() => _isCapturing = true);
    try {
      final image = await _controller!.takePicture();

      if (kIsWeb) {
        // Untuk web, konversi XFile ke base64 URL
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        final imageUrl = 'data:image/jpeg;base64,$base64Image';

        setState(() {
          _capturedImage = image;
          _capturedImageUrl = imageUrl;
        });
      } else {
        // Untuk mobile, gunakan path biasa
        setState(() {
          _capturedImage = image;
        });
      }
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
      _initCamera();
      _capturedImage = null;
      _capturedImageUrl = null;
    });
  }

  Future<void> _uploadAndReturn() async {
    if (_capturedImage == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    if (kIsWeb) {
      await _uploadImageForWeb(authState);
      return;
    }

    // Handle mobile upload
    final imageFile = File(_capturedImage!.path);
    final contentType = lookupMimeType(_capturedImage!.path) ?? 'image/jpeg';
    final fileName = 'Jawaban/user-${authState.id}-ujian-${widget.soal.idUjian}-soal-${widget.soal.id}${extension(imageFile.path)}';

    context.read<CloudflareBloc>().add(
      UploadFile(
        token: authState.token,
        fileContent: imageFile,
        fileName: fileName,
        contentType: contentType,
      ),
    );

    context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(
        token: authState.token,
        ujianId: widget.soal.idUjian,
        soalId: widget.soal.id,
        jawaban: 'https://edukasiin.animein.net/$fileName',
        nilai: 0,
        userId: authState.id
    ));

    Navigator.pop(context, _capturedImage!.path);
  }

  Future<void> _uploadImageForWeb(Authenticated authState) async {
    try {
      setState(() => _isUploading = true);

      if (_capturedImage == null) return;

      // Convert XFile to bytes untuk web
      final bytes = await _capturedImage!.readAsBytes();
      final fileName = 'Jawaban/user-${authState.id}-ujian-${widget.soal.idUjian}-soal-${widget.soal.id}.jpg';
      final contentType = 'image/jpeg';

      context.read<CloudflareBloc>().add(
        UploadFile(
          token: authState.token,
          fileWeb: bytes,
          fileName: fileName,
          contentType: contentType,
        ),
      );

      // Update jawaban siswa
      context.read<JawabanSiswaBloc>().add(UpdateJawabanSiswa(
          token: authState.token,
          ujianId: widget.soal.idUjian,
          soalId: widget.soal.id,
          jawaban: 'https://edukasiin.animein.net/$fileName',
          nilai: 0,
          userId: authState.id
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto berhasil diupload')),
      );

      Navigator.pop(context, _capturedImage!.path);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload foto: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String extension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  Widget _buildCapturedImage(double screenWidth) {
    if (_capturedImage == null) return Container();

    if (kIsWeb) {
      // Untuk web, gunakan Image.network dengan base64 URL
      return _capturedImageUrl != null
          ? Image.network(
        _capturedImageUrl!,
        fit: BoxFit.cover,
        width: screenWidth < 600 ? double.infinity : 600,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Gagal menampilkan gambar'),
                SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      )
          : Center(child: CircularProgressIndicator());
    } else {
      // Untuk mobile, gunakan Image.file
      return Image.file(
        File(_capturedImage!.path),
        fit: BoxFit.cover,
        width: screenWidth < 600 ? double.infinity : 600,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Gagal menampilkan gambar'),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Kamera')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cameras == null || _cameras!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Kamera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Kamera tidak tersedia'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ambil Foto Jawaban'),
        actions: [
          if (_capturedImage != null && !_isUploading)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _uploadAndReturn,
            ),
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints){
              final screenWidth = constraints.maxWidth;

              if(_capturedImage != null){
                return _buildCapturedImage(screenWidth);
              }
              else if(_controller != null && _controller!.value.isInitialized){
                return CameraPreview(_controller!);
              }
              else{
                return Center(child: CircularProgressIndicator());
              }
            }
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_capturedImage != null)
                  FloatingActionButton(
                    onPressed: _isUploading ? null : _retakePicture,
                    heroTag: 'retake',
                    child: Icon(Icons.arrow_back),
                  ),
                SizedBox(width: 20),
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