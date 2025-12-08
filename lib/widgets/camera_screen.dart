import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  const CameraScreen(
      {super.key, required this.soal, required this.questionIndex});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isLoading = true;
  bool _isCapturing = false;
  bool _isUploading = false;
  XFile? _capturedImage;
  String? _capturedImageUrl;
  int _currentCameraIndex = 0;
  Size _targetSize = Size.zero;
  double _aspectRatio = 16 / 10; // Aspek rasio yang diinginkan
  bool _isPortrait = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTargetSize();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateTargetSize();
  }

  void _updateTargetSize() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isPortrait = screenHeight > screenWidth;

          // Hitung ukuran target berdasarkan aspek rasio
          if (screenWidth < 600) {
            final targetWidth = screenWidth - 32.0; // Konversi ke double
            final targetHeight = targetWidth * _aspectRatio;
            _targetSize = Size(targetWidth, targetHeight);
          } else {
            final targetWidth = 600.0;
            final targetHeight = targetWidth * _aspectRatio;
            _targetSize = Size(targetWidth, targetHeight);
          }
        });
      }
    });
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        await _initializeCamera(0);
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

  Future<void> _initializeCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    // Pilih resolusi preset yang sesuai
    ResolutionPreset selectedPreset = ResolutionPreset.medium;

    // Coba set preset berdasarkan kebutuhan
    if (_targetSize.width > 0 && _targetSize.height > 0) {
      final targetPixels = _targetSize.width * _targetSize.height;

      if (targetPixels >= 1920 * 1080) {
        selectedPreset = ResolutionPreset.high;
      } else if (targetPixels >= 1280 * 720) {
        selectedPreset = ResolutionPreset.medium;
      } else if (targetPixels >= 640 * 480) {
        selectedPreset = ResolutionPreset.medium;
      } else {
        selectedPreset = ResolutionPreset.medium;
      }
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      selectedPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentCameraIndex = cameraIndex;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menginisialisasi kamera: $e')),
      );
    }
  }

  Future<void> _rotateCamera() async {
    if (_isCapturing || !_controller!.value.isInitialized || _cameras!.length <= 1) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Hitung indeks kamera berikutnya
      int nextCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;

      // Inisialisasi kamera baru
      await _initializeCamera(nextCameraIndex);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengganti kamera: $e')),
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
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageFile = File(_capturedImage!.path);
    final contentType = lookupMimeType(_capturedImage!.path) ?? 'image/jpeg';
    final fileName = 'Jawaban/user-${authState.id}-ujian-${widget.soal.idUjian}-soal-${widget.soal.id}-$timestamp${extension(imageFile.path)}';

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
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final bytes = await _capturedImage!.readAsBytes();
      final fileName = 'Jawaban/user-${authState.id}-ujian-${widget.soal.idUjian}-soal-${widget.soal.id}-$timestamp.jpg';
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

    final targetWidth = screenWidth < 600 ? screenWidth - 32.0 : 600.0;
    final targetHeight = targetWidth * _aspectRatio;

    if (kIsWeb) {
      // Untuk web, gunakan Image.network dengan base64 URL
      return _capturedImageUrl != null
          ? Container(
        width: targetWidth,
        height: targetHeight,
        child: Image.network(
          _capturedImageUrl!,
          fit: BoxFit.cover,
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
        ),
      )
          : Center(child: CircularProgressIndicator());
    } else {
      // Untuk mobile, gunakan Image.file
      return Container(
        width: targetWidth,
        height: targetHeight,
        child: Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.cover,
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
        ),
      );
    }
  }

  Widget _buildCameraPreview(double screenWidth) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    final targetWidth = screenWidth < 600 ? screenWidth - 32.0 : 600.0;
    final targetHeight = targetWidth * _aspectRatio;

    return Container(
      width: targetWidth,
      height: targetHeight,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: _isPortrait
                  ? _controller!.value.previewSize!.height.toDouble()
                  : _controller!.value.previewSize!.width.toDouble(),
              height: _isPortrait
                  ? _controller!.value.previewSize!.width.toDouble()
                  : _controller!.value.previewSize!.height.toDouble(),
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCameraIcon() {
    if (_cameras == null || _cameras!.isEmpty) {
      return Icon(Icons.camera_alt);
    }

    if (_cameras!.length == 1) {
      return Icon(Icons.camera_alt);
    }

    // Tentukan ikon berdasarkan jenis kamera
    final cameraLensDirection = _cameras![_currentCameraIndex].lensDirection;

    switch (cameraLensDirection) {
      case CameraLensDirection.front:
        return Icon(Icons.camera_front);
      case CameraLensDirection.back:
        return Icon(Icons.camera_rear);
      default:
        return Icon(Icons.camera_rear);
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
                builder: (context, constraints){
                  final screenWidth = constraints.maxWidth;

                  if(_capturedImage != null){
                    return Center(
                      child: _buildCapturedImage(screenWidth.toDouble()), // Konversi ke double
                    );
                  }
                  else if(_controller != null && _controller!.value.isInitialized){
                    return Center(
                      child: _buildCameraPreview(screenWidth.toDouble()), // Konversi ke double
                    );
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
                  if (_capturedImage == null)...[
                    FloatingActionButton(
                      onPressed: _takePicture,
                      heroTag: 'capture',
                      child: _isCapturing
                          ? CircularProgressIndicator(color: Colors.white)
                          : Icon(Icons.camera_alt),
                    ),
                    if (_cameras!.length > 1) SizedBox(width: 20),
                    if (_cameras!.length > 1)
                      FloatingActionButton(
                        onPressed: _rotateCamera,
                        heroTag: 'rotate',
                        child: _getCameraIcon(),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
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