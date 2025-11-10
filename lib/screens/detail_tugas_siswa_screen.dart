import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_bloc.dart';
import 'package:project_ta/bloc/history_tugas/history_tugas_event.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/tugas_model.dart';
import 'package:project_ta/screens/history_tugas_screen.dart';
import 'package:project_ta/widgets/audio_player_tugas.dart';
import 'package:project_ta/widgets/video_player_tugas.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:universal_html/html.dart' as html;
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/pengumpulan_tugas/pengumpulan_tugas_bloc.dart';
import '../bloc/pengumpulan_tugas/pengumpulan_tugas_event.dart';
import '../bloc/pengumpulan_tugas/pengumpulan_tugas_state.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';
import '../services/notification_service.dart';
import '../widgets/audio_player.dart';
import '../widgets/video_player.dart';

class DetailTugasSiswaScreen extends StatefulWidget {
  final TugasModel tugas;

  const DetailTugasSiswaScreen({super.key, required this.tugas});

  @override
  State<DetailTugasSiswaScreen> createState() => _DetailTugasSiswaScreenState();
}

class _DetailTugasSiswaScreenState extends State<DetailTugasSiswaScreen> {
  final TextEditingController _deskripsiController = TextEditingController();

  String? _gambarPath;
  String? _videoPath;
  String? _audioPath;
  String? _filePath;

  // Variabel untuk download
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String _downloadStatus = '';
  String? _currentDownloadUrl;

  Future<void> _pickFile(String type, BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    // Untuk platform web
    if (kIsWeb) {
      await _pickFileForWeb(type, authState, context);
      return;
    }

    // Untuk platform mobile (kode asli)
    FilePickerResult? result;
    String contentType = 'application/octet-stream';
    String prefix = '';

    if (type == 'gambar') {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
      contentType = 'image/jpeg';
      prefix = 'Tugas/Gambar';
    } else if (type == 'video') {
      result = await FilePicker.platform.pickFiles(type: FileType.video);
      contentType = 'video/mp4';
      prefix = 'Tugas/Video';
    } else if (type == 'audio') {
      result = await FilePicker.platform.pickFiles(type: FileType.audio);
      contentType = 'audio/mpeg';
      prefix = 'Tugas/Audio';
    } else {
      result = await FilePicker.platform.pickFiles(type: FileType.any);
      contentType = 'application/pdf';
      prefix = 'Tugas/File';
    }

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$prefix/${widget.tugas.nama}-$timestamp${_extension(file.path)}';

      // Dispatch ke cloudflare bloc
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileContent: file,
          contentType: contentType,
          token: authState.token,
        ),
      );

      _updateFilePath(type, 'Uploading...');
    }
  }

  // Fungsi baru untuk handle file pick di web
  Future<void> _pickFileForWeb(String type, Authenticated authState, BuildContext context) async {
    try {
      FilePickerResult? result;
      String contentType = 'application/octet-stream';
      String prefix = '';

      // Konfigurasi berdasarkan tipe file
      if (type == 'gambar') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        contentType = 'image/jpeg';
        prefix = 'Tugas/Gambar';
      } else if (type == 'video') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
        contentType = 'video/mp4';
        prefix = 'Tugas/Video';
      } else if (type == 'audio') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
        contentType = 'audio/mpeg';
        prefix = 'Tugas/Audio';
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
        contentType = 'application/pdf';
        prefix = 'Tugas/File';
      }

      if (result != null && result.files.single.bytes != null) {
        final platformFile = result.files.single;
        final bytes = platformFile.bytes!;

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final originalFileName = platformFile.name;
        final fileExtension = _getWebExtension(originalFileName, type);
        final fileName = '$prefix/${widget.tugas.nama}-$timestamp$fileExtension';

        // Update UI untuk menunjukkan upload sedang berlangsung
        _updateFilePath(type, 'Uploading...');

        // Dispatch ke cloudflare bloc dengan fileWeb untuk web
        context.read<CloudflareBloc>().add(
          UploadFile(
            token: authState.token,
            fileWeb: bytes, // Gunakan bytes untuk web
            fileName: fileName,
            contentType: contentType,
          ),
        );

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File $type berhasil diupload')),
        );

      } else if (result != null && result.files.single.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membaca file')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload file: $e')),
      );
      _updateFilePath(type, ''); // Reset jika gagal
    }
  }

  // Helper function untuk mendapatkan extension file di web
  String _getWebExtension(String fileName, String type) {
    final ext = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));

    // Default extension berdasarkan tipe
    if (ext.isEmpty || ext == '.') {
      switch (type) {
        case 'gambar':
          return '.jpg';
        case 'video':
          return '.mp4';
        case 'audio':
          return '.mp3';
        default:
          return '.pdf';
      }
    }

    return ext;
  }

  // Helper function untuk update file path di state
  void _updateFilePath(String type, String path) {
    setState(() {
      if (type == 'gambar') _gambarPath = path;
      if (type == 'video') _videoPath = path;
      if (type == 'audio') _audioPath = path;
      if (type == 'doc') _filePath = path;
    });
  }

  String _extension(String path) => path.substring(path.lastIndexOf('.'));

  // Fungsi untuk download file
  Future<void> _downloadFile(String url, String fileName, BuildContext context) async {
    // Generate unique notification ID untuk setiap download
    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
        _downloadStatus = 'Memulai download...';
        _currentDownloadUrl = url;
      });

      // Tampilkan notifikasi progress awal
      await NotificationService.showDownloadNotification(
        title: 'Memulai Download',
        body: 'Mempersiapkan $fileName...',
        progress: 0,
        isProgress: true,
        notificationId: notificationId,
      );

      print("Downloading from: $url");

      if (kIsWeb) {
        await _downloadFileForWebWithProgress(url, fileName, context);
        return;
      }

      // Untuk platform mobile
      String extension = getFileExtensionFromUrl(url);

      // Request permission untuk mobile
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {

        final String savePath = '/storage/emulated/0/Download/$fileName$extension';
        final Dio dio = Dio();

        setState(() {
          _downloadStatus = 'Sedang mengunduh...';
        });

        // Update notifikasi progress
        await NotificationService.showDownloadNotification(
          title: 'Mengunduh $fileName',
          body: '0% - Memulai download...',
          progress: 0,
          isProgress: true,
          notificationId: notificationId,
        );

        await dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toInt();
              final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
              final totalMB = (total / 1024 / 1024).toStringAsFixed(1);

              setState(() {
                _downloadProgress = progress.toDouble();
                _downloadStatus = '$receivedMB MB / $totalMB MB';
              });

              // Update notifikasi progress
              NotificationService.showDownloadNotification(
                title: 'Mengunduh $fileName',
                body: '$progress% - $receivedMB MB / $totalMB MB',
                progress: progress,
                isProgress: true,
                notificationId: notificationId,
              );
            }
          },
        );

        // Hapus notifikasi progress dan tampilkan notifikasi sukses
        await NotificationService.cancelProgressNotification(notificationId);
        await NotificationService.showDownloadNotification(
          title: 'Download Berhasil ✅',
          body: '$fileName$extension berhasil disimpan di Folder Download',
        );

        _showDownloadSuccess(context, 'File berhasil didownload ke Folder Download');
        print("File downloaded successfully to: $savePath");

      } else {
        setState(() {
          _isDownloading = false;
          _downloadStatus = 'Izin ditolak';
          _currentDownloadUrl = null;
        });

        // Notifikasi error permission
        await NotificationService.cancelProgressNotification(notificationId);
        await NotificationService.showDownloadNotification(
          title: 'Download Gagal ❌',
          body: 'Izin penyimpanan ditolak untuk $fileName',
        );

        _showDownloadError(context, 'Izin penyimpanan ditolak');
        print("Storage permission denied");
      }
    } catch (e) {
      // Handle error dengan notifikasi
      await NotificationService.cancelProgressNotification(notificationId);
      await NotificationService.showDownloadNotification(
        title: 'Download Gagal ❌',
        body: 'Gagal mendownload $fileName: ${e.toString()}',
      );

      _handleDownloadError(context, e);
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  // Method alternatif untuk download di web dengan progress tracking
  Future<void> _downloadFileForWebWithProgress(String url, String fileName, BuildContext context) async {
    try {
      setState(() {
        _downloadStatus = 'Mempersiapkan download...';
      });


      final String fullFileName = fileName;

      // Download file sebagai blob untuk tracking progress
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100);
            setState(() {
              _downloadProgress = progress;
              _downloadStatus = '${(received / 1024 / 1024).toStringAsFixed(1)} MB / ${(total / 1024 / 1024).toStringAsFixed(1)} MB';
            });
          }
        },
      );

      // Convert ke blob dan create download link
      final bytes = response.data as List<int>;
      final blob = html.Blob([bytes]);
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      // Create anchor element untuk download
      final anchorElement = html.AnchorElement(href: blobUrl);
      anchorElement.download = fullFileName;
      anchorElement.style.display = 'none';

      html.document.body?.append(anchorElement);
      anchorElement.click();
      anchorElement.remove();

      // Cleanup
      html.Url.revokeObjectUrl(blobUrl);

      _showDownloadSuccess(context, 'File berhasil didownload');

    } catch (e) {
      _handleDownloadError(context, e);
    }
  }

  // Helper functions untuk konsistensi
  void _showDownloadSuccess(BuildContext context, String message) {
    setState(() {
      _isDownloading = false;
      _downloadStatus = 'Download selesai!';
      _currentDownloadUrl = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDownloadError(BuildContext context, String message) {
    setState(() {
      _isDownloading = false;
      _downloadStatus = message;
      _currentDownloadUrl = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDownloadError(BuildContext context, dynamic error) {
    setState(() {
      _isDownloading = false;
      _downloadStatus = 'Error: ${error.toString()}';
      _currentDownloadUrl = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error downloading file: $error'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String getFileExtensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final String pathWithoutQuery = uri.path;
    return path.extension(pathWithoutQuery);
  }

  // Widget untuk menampilkan media dalam grid responsive
  Widget _buildMediaGrid(TugasModel tugas) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final mediaWidgets = _buildMediaWidgets(tugas);

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
          itemBuilder: (context, index) => LayoutBuilder(
            // Tambahkan LayoutBuilder di setiap item grid
            builder: (context, itemConstraints) {
              return _buildMediaItemWithConstraints(
                mediaWidgets[index],
                tugas,
                itemConstraints,
              );
            },
          ),
        );
      },
    );
  }

  // Helper function untuk menentukan jumlah kolom
  int _getCrossAxisCount(double maxWidth) {
    if (maxWidth > 1200) return 3; // Layar besar (desktop)
    if (maxWidth > 600) return 2;  // Layar sedang (tablet)
    return 1; // Layar kecil (mobile)
  }

  // Fungsi untuk menentukan aspect ratio berdasarkan jumlah kolom
  double _getAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1: return 12 / 9;  // Lebar landscape untuk 1 kolom
      case 2: return 12 / 9; // Sedikit lebih persegi untuk 2 kolom
      case 3: return 12 / 9; // Persegi untuk 3 kolom
      default: return 12 / 9;
    }
  }

  Widget _buildMediaItemWithConstraints(int wigets, TugasModel tugas, BoxConstraints constraints) {
    if (wigets == 1) {
      return _buildImagePreview(tugas.linkGambar, constraints);
    }
    else if(wigets == 2){
      return _buildVideoPreview(tugas.linkVideo, constraints);
    }
    else if(wigets == 3){
      return _buildAudioPreview(tugas.linkAudio, constraints);
    }
    else if(wigets == 4){
      return _buildFilePreview(tugas.linkFile, constraints);
    }


    return Text('kosong');
  }

  // Kumpulkan semua widget media
  List<int> _buildMediaWidgets(TugasModel tugas) {
    final mediaWidgets = <int>[];

    if (tugas.linkGambar != '-') {
      mediaWidgets.add(1);
    }

    if (tugas.linkVideo != '-') {
      mediaWidgets.add(2);
    }

    if (tugas.linkAudio != '-') {
      mediaWidgets.add(3);
    }

    if (tugas.linkFile != '-') {
      mediaWidgets.add(4);
    }

    return mediaWidgets;
  }

  // Widget untuk preview gambar
  Widget _buildImagePreview(String imageUrl, BoxConstraints constraints) {
    final isDownloadingThisFile = _isDownloading && _currentDownloadUrl == imageUrl;

    return _buildMediaContainer(
      child: Column(
        children: [
          _buildMediaListTile(
            icon: Icons.image,
            iconColor: Colors.orange.shade700,
            title: "Gambar",
            subtitle: "File gambar terlampir",
            isDownloading: isDownloadingThisFile,
            onDownload: () => _downloadFile(imageUrl, widget.tugas.linkGambar, context),
          ),
          _buildImageContent(imageUrl, constraints), // Pass constraints ke image content
        ],
      ),
    );
  }

  // Widget untuk preview video
  Widget _buildVideoPreview(String videoUrl, BoxConstraints constraints) {
    final isDownloadingThisFile = _isDownloading && _currentDownloadUrl == videoUrl;

    return _buildMediaContainer(
      child: Column(
        children: [
          _buildMediaListTile(
            icon: Icons.videocam,
            iconColor: Colors.red.shade700,
            title: "Video",
            subtitle: "File video terlampir",
            isDownloading: isDownloadingThisFile,
            onDownload: () => _downloadFile(videoUrl, widget.tugas.linkVideo, context),
          ),
          _buildVideoContent(videoUrl, constraints),
        ],
      ),
    );
  }

  // Widget untuk preview audio
  Widget _buildAudioPreview(String audioUrl, BoxConstraints constraints) {
    final isDownloadingThisFile = _isDownloading && _currentDownloadUrl == audioUrl;

    return _buildMediaContainer(
      child: Column(
        children: [
          _buildMediaListTile(
            icon: Icons.audiotrack,
            iconColor: Colors.purple.shade700,
            title: "Audio",
            subtitle: "File audio terlampir",
            isDownloading: isDownloadingThisFile,
            onDownload: () => _downloadFile(audioUrl, widget.tugas.linkAudio, context),
          ),
          _buildAudioContent(audioUrl, constraints),
        ],
      ),
    );
  }

  // Widget untuk preview file
  Widget _buildFilePreview(String fileUrl, BoxConstraints constraints) {
    final isDownloadingThisFile = _isDownloading && _currentDownloadUrl == fileUrl;
    final extension = _extension(fileUrl);

    if (kIsWeb) {
      return _buildMediaContainer(
        child: Column(
          children: [
            _buildMediaListTile(
              icon: Icons.insert_drive_file,
              iconColor: Colors.blue.shade700,
              title: "Dokumen",
              subtitle: "File dokumen terlampir",
              isDownloading: isDownloadingThisFile,
              onDownload: () => _downloadFile(fileUrl, widget.tugas.linkFile, context),
            ),
            if(extension != '.pdf')...[
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Untuk File selain PDF silahkan didownload',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]
            else...[
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'PDF Preview tidak tersedia di browser',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Buka PDF di tab baru
                  html.window.open(fileUrl, '_blank');
                },
                child: Text('Buka PDF di Tab Baru'),
              ),
            ]
          ],
        ),
      );
    } else {
      return _buildMediaContainer(
        child: Column(
          children: [
            _buildMediaListTile(
              icon: Icons.insert_drive_file,
              iconColor: Colors.blue.shade700,
              title: "Dokumen",
              subtitle: "File dokumen terlampir",
              isDownloading: isDownloadingThisFile,
              onDownload: () => _downloadFile(fileUrl, widget.tugas.linkFile, context),
            ),
            if(extension != '.pdf')...[
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Untuk File selain PDF silahkan didownload',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ]
            else _buildFileContent(fileUrl, constraints),
          ],
        ),
      );
    }
  }

  // Reusable container untuk media
  Widget _buildMediaContainer({required Widget child}) {
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
      child: child,
    );
  }

  // Reusable ListTile untuk media
  Widget _buildMediaListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDownloading,
    required VoidCallback onDownload,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: isDownloading
          ? _buildDownloadProgress()
          : _buildDownloadButton(onDownload),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Widget untuk progress download
  Widget _buildDownloadProgress() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        value: _downloadProgress / 100,
        strokeWidth: 3,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  // Widget untuk download button
  Widget _buildDownloadButton(VoidCallback onDownload) {
    return IconButton(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.download,
          color: Colors.blue.shade700,
          size: 18,
        ),
      ),
      onPressed: onDownload,
    );
  }

  // Konten untuk gambar
  Widget _buildImageContent(String imageUrl, BoxConstraints constraints) {
    // Hitung maxHeight berdasarkan constraints parent
    // constraints.maxHeight adalah tinggi dari container grid item
    final maxHeight = constraints.maxHeight * 0.6; // 60% dari tinggi parent

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
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
            return _buildLoadingPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder(
              icon: Icons.broken_image,
              message: 'Gagal memuat gambar',
            );
          },
        ),
      ),
    );
  }

  // Konten untuk video
  Widget _buildVideoContent(String videoUrl, BoxConstraints constraints) {
    final maxHeight = constraints.maxHeight * 0.6;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
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

  // Konten untuk audio
  Widget _buildAudioContent(String audioUrl, BoxConstraints constraints) {
    final maxHeight = constraints.maxHeight * 0.6;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: AudioPreviewWidget(audioUrl: audioUrl),
    );
  }

  // Konten untuk file
  Widget _buildFileContent(String fileUrl, BoxConstraints constraints) {
    final maxHeight = constraints.maxHeight * 0.6;
    return Container(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: maxHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SfPdfViewer.network(
          fileUrl,
          initialZoomLevel: 1.0,
        ),
      ),
    );
  }

  // Placeholder untuk loading
  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Placeholder untuk error
  Widget _buildErrorPlaceholder({required IconData icon, required String message}) {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tugas = widget.tugas;
    final isDeadlineNear = tugas.deadline.difference(DateTime.now()).inDays <= 3;
    final isOverdue = tugas.deadline.isBefore(DateTime.now());
    final isTerkumpul = tugas.mengumpulkan;

    return BlocListener<CloudflareBloc, CloudflareState>(
      listener: (context, state) {
        if (state is CloudFlareLoaded) {
          setState(() {
            if (state.fileName.contains('Tugas/Gambar')) _gambarPath = 'https://edukasiin.animein.net/${state.fileName}';
            if (state.fileName.contains('Tugas/Video')) _videoPath = 'https://edukasiin.animein.net/${state.fileName}';
            if (state.fileName.contains('Tugas/Audio')) _audioPath = 'https://edukasiin.animein.net/${state.fileName}';
            if (state.fileName.contains('Tugas/File')) _filePath = 'https://edukasiin.animein.net/${state.fileName}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File berhasil diupload"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is CloudFlareError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Upload gagal: ${state.message}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Detail Tugas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: BlocConsumer<PengumpulanTugasBloc, PengumpulanTugasState>(
            listener: (context, state) {
              if (state is PengumpulanTugasSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Tugas berhasil dikumpulkan!"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              }
              if (state is PengumpulanTugasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: ${state.message}"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is PengumpulanTugasLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Mengirim tugas...",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card - Informasi Tugas
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tugas.nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      tugas.deskripsi,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Divider(height: 1),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: isOverdue
                                              ? Colors.red
                                              : isDeadlineNear
                                              ? Colors.orange
                                              : Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Deadline: ${_formatDate(tugas.deadline)}",
                                            style: TextStyle(
                                              color: isOverdue
                                                  ? Colors.red
                                                  : isDeadlineNear
                                                  ? Colors.orange
                                                  : Colors.grey.shade700,
                                              fontWeight: isOverdue || isDeadlineNear
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (isOverdue)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "Terlambat",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else if (isDeadlineNear)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "Mendekati deadline",
                                              style: TextStyle(
                                                color: Colors.orange.shade800,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.class_,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Kelas: ${tugas.kelas}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // File Attachments Section
                          Center(
                              child: Text(
                                "File Terlampir dari Tugas",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue.shade800,
                                ),
                              )
                          ),
                          SizedBox(height: 12),

                          // Gambar Card
                          _buildMediaGrid(widget.tugas),

                          // Jika tidak ada file yang dilampirkan
                          if (widget.tugas.linkGambar == '-' &&
                              widget.tugas.linkVideo == '-' &&
                              widget.tugas.linkAudio == '-' &&
                              widget.tugas.linkFile == '-')
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Tidak ada file yang dilampirkan",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Button history tugas
                          if(isTerkumpul)...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<HistoryTugasBloc>().add(InitialHistoryTugas());
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HistoryTugasScreen(tugasId: tugas.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "History Pengumpulan",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],

                          // Upload Media Section
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Lampirkan File",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildMediaButton('Gambar', Icons.image, Colors.orange, () => _pickFile('gambar', context)),
                                        _buildMediaButton('Video', Icons.videocam, Colors.red, () => _pickFile('video', context)),
                                        _buildMediaButton('Audio', Icons.audiotrack, Colors.purple, () => _pickFile('audio', context)),
                                        _buildMediaButton('File', Icons.insert_drive_file, Colors.blue, () => _pickFile('doc', context)),
                                      ],
                                    ),
                                  ]
                                ),
                              ),
                            ),
                          ),

                          // File Preview Section
                          if (_gambarPath != null || _videoPath != null || _audioPath != null || _filePath != null)
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "File Terlampir",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      _buildMediaPreview(),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Deskripsi Pengumpulan
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Deskripsi Pengumpulan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    TextField(
                                      controller: _deskripsiController,
                                      decoration: InputDecoration(
                                        hintText: "Tambahkan deskripsi untuk tugas Anda...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      maxLines: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final authState = context.read<AuthBloc>().state;
                                context.read<TugasBloc>().add(TugasInit());
                                if (authState is Authenticated) {
                                  context.read<PengumpulanTugasBloc>().add(
                                    SubmitPengumpulanTugas(
                                      idUser: authState.id,
                                      idTugas: tugas.id,
                                      deskripsi: _deskripsiController.text,
                                      token: authState.token,
                                      gambarPath: _gambarPath,
                                      videoPath: _videoPath,
                                      audioPath: _audioPath,
                                      filePath: _filePath,
                                    ),
                                  );

                                  context.read<HistoryTugasBloc>().add(CreateHistoryTugas(token: authState.token, userId: authState.id, tugasId: tugas.id,));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Kumpulkan Tugas",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Progress Download di Paling Bawah
                  if (_isDownloading)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.shade300)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Downloading File',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isDownloading = false;
                                    _currentDownloadUrl = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _downloadProgress / 100,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_downloadProgress.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _downloadStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 24),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_gambarPath != null && _gambarPath != '-')
          _buildFileChip(
            'Gambar',
            Icons.image,
            Colors.orange,
            _gambarPath!,
          ),
        if (_videoPath != null && _videoPath != '-')
          _buildFileChip(
            'Video',
            Icons.videocam,
            Colors.red,
            _videoPath!,
          ),
        if (_audioPath != null && _audioPath != '-')
          _buildFileChip(
            'Audio',
            Icons.audiotrack,
            Colors.purple,
            _audioPath!,
          ),
        if (_filePath != null && _filePath != '-')
          _buildFileChip(
            'File',
            Icons.insert_drive_file,
            Colors.blue,
            _filePath!,
          ),
      ],
    );
  }

  Widget _buildFileChip(String type, IconData icon, Color color, String path) {
    final isUploading = path == 'Uploading...';
    final fileName = isUploading ? 'Mengupload...' : path.split('/').last;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isUploading
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
              : Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}