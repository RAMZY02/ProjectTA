import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedVideo;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;
  String? _uploadSuccess;

  Future<void> _selectVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedVideo = File(result.files.single.path!);
          _uploadError = null;
          _uploadSuccess = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to select video: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
      _uploadSuccess = null;
    });

    try {
      // Replace these with your actual Cloudflare R2 credentials
      const String endpoint = 'YOUR_CLOUDFLARE_R2_ENDPOINT';
      const String accessKeyId = 'YOUR_ACCESS_KEY_ID';
      const String secretAccessKey = 'YOUR_SECRET_ACCESS_KEY';
      const String bucketName = 'YOUR_BUCKET_NAME';

      final uri = Uri.parse('$endpoint/$bucketName/${path.basename(_selectedVideo!.path)}');
      final request = http.MultipartRequest('PUT', uri);

      // Set headers for S3-compatible API
      request.headers['x-amz-acl'] = 'public-read';
      request.headers['Content-Type'] = lookupMimeType(_selectedVideo!.path) ?? 'application/octet-stream';

      // Add authorization headers (you might need to adjust this based on your R2 setup)
      request.headers['Authorization'] = 'AWS $accessKeyId:${_generateSignature(secretAccessKey, request)}';

      // Add the file to upload
      final fileStream = http.ByteStream(_selectedVideo!.openRead());
      final length = await _selectedVideo!.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: path.basename(_selectedVideo!.path),
      );

      request.files.add(multipartFile);

      // Track upload progress
      final response = await request.send();
      response.stream.listen((List<int> chunk) {
        setState(() {
          _uploadProgress += chunk.length / length;
        });
      }).onDone(() async {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          setState(() {
            _uploadSuccess = 'Video uploaded successfully!';
          });
        } else {
          setState(() {
            _uploadError = 'Upload failed with status ${response.statusCode}';
          });
        }
        setState(() {
          _isUploading = false;
        });
      });
    } catch (e) {
      setState(() {
        _uploadError = 'Upload failed: ${e.toString()}';
        _isUploading = false;
      });
    }
  }

  // Helper method to generate AWS signature (simplified version)
  String _generateSignature(String secretAccessKey, http.MultipartRequest request) {
    // In a real app, you should implement proper AWS signature v4
    // This is a simplified placeholder
    return 'your-signature';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video selection card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.video_library, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      _selectedVideo?.path.split('/').last ?? 'No video selected',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selectVideo,
                      child: const Text('Select Video'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Video preview (if selected)
            if (_selectedVideo != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedVideo != null
                      ? const Center(
                    child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                  )
                      : const Center(child: Text('Video preview')),
                ),
              ),

            const SizedBox(height: 24),

            // Upload progress indicator
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  const SizedBox(height: 8),
                  Text('Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%'),
                ],
              ),

            // Error message
            if (_uploadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _uploadError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Success message
            if (_uploadSuccess != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _uploadSuccess!,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(),

            // Upload button
            ElevatedButton(
              onPressed: _selectedVideo != null && !_isUploading ? _uploadVideo : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Upload to Cloudflare R2'),
            ),
          ],
        ),
      ),
    );
  }
}