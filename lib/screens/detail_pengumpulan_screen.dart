import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/pengumpulan_tugas/pengumpulan_tugas_bloc.dart';
import 'package:project_ta/bloc/pengumpulan_tugas/pengumpulan_tugas_event.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/tugas_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:universal_html/html.dart' as html;
import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_event.dart';
import '../models/pengumpulan_tugas_model.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../widgets/audio_player.dart';
import '../widgets/video_player.dart';

class PengumpulanDetailScreen extends StatefulWidget {
  final UserModel p;
  const PengumpulanDetailScreen({super.key, required this.p});

  @override
  _PengumpulanDetailScreenState createState() => _PengumpulanDetailScreenState();
}

class _PengumpulanDetailScreenState extends State<PengumpulanDetailScreen> {
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String _downloadStatus = '';
  String? _currentDownloadUrl;
  TextEditingController _nilaiController = TextEditingController();

  @override
  void dispose() {
    _nilaiController.dispose();
    super.dispose();
  }

  // Widget untuk menampilkan media dalam grid responsive
  Widget _buildMediaGrid(PengumpulanTugasModel tugas) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tentukan jumlah kolom berdasarkan lebar layar
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        // Kumpulkan semua media yang ada
        final mediaWidgets = _buildMediaWidgets(tugas);

        // Tampilkan dalam grid
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
          itemBuilder: (context, index) => mediaWidgets[index],
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
      case 1: return 9 / 9;  // Lebar landscape untuk 1 kolom
      case 2: return 11 / 9; // Sedikit lebih persegi untuk 2 kolom
      case 3: return 11 / 9; // Persegi untuk 3 kolom
      default: return 11 / 9;
    }
  }

  // Kumpulkan semua widget media
  List<Widget> _buildMediaWidgets(PengumpulanTugasModel tugas) {
    final mediaWidgets = <Widget>[];

    if (tugas.linkGambar != '-') {
      mediaWidgets.add(_buildImagePreview(tugas.linkGambar));
    }

    if (tugas.linkVideo != '-') {
      mediaWidgets.add(_buildVideoPreview(tugas.linkVideo));
    }

    if (tugas.linkAudio != '-') {
      mediaWidgets.add(_buildAudioPreview(tugas.linkAudio));
    }

    if (tugas.linkFile != '-') {
      mediaWidgets.add(_buildFilePreview(tugas.linkFile));
    }

    return mediaWidgets;
  }

  // Widget untuk preview gambar
  Widget _buildImagePreview(String imageUrl) {
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
            onDownload: () => _downloadFile(imageUrl, widget.p, context),
          ),
          _buildImageContent(imageUrl),
        ],
      ),
    );
  }

  // Widget untuk preview video
  Widget _buildVideoPreview(String videoUrl) {
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
            onDownload: () => _downloadFile(videoUrl, widget.p, context),
          ),
          _buildVideoContent(videoUrl),
        ],
      ),
    );
  }

  // Widget untuk preview audio
  Widget _buildAudioPreview(String audioUrl) {
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
            onDownload: () => _downloadFile(audioUrl, widget.p, context),
          ),
          _buildAudioContent(audioUrl),
        ],
      ),
    );
  }

  // Widget untuk preview file
  Widget _buildFilePreview(String fileUrl) {
    final isDownloadingThisFile = _isDownloading && _currentDownloadUrl == fileUrl;

    if (kIsWeb) {
      return Column(
        children: [
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
        ],
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
              onDownload: () => _downloadFile(fileUrl, widget.p, context),
            ),
            _buildFileContent(fileUrl),
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
  Widget _buildImageContent(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
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
  Widget _buildVideoContent(String videoUrl) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
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
  Widget _buildAudioContent(String audioUrl) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      child: AudioPreviewWidget(audioUrl: audioUrl),
    );
  }

  // Konten untuk file
  Widget _buildFileContent(String fileUrl) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 280,
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

  void _simpanNilai(int nilai) {

    context.read<UsersBloc>().add(Init());
    final authState = context.read<AuthBloc>().state;
    if(authState is Authenticated){
      context.read<PengumpulanTugasBloc>().add(UpdatePengumpulanNilai(id: widget.p.tugas!.id, token: authState.token, nilai: nilai));
    }


    // Tampilkan konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nilai berhasil disimpan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Reset form
    _nilaiController.clear();

    // Tutup keyboard
    FocusScope.of(context).unfocus();
  }

  Future<void> _downloadFile(String url, UserModel siswa, BuildContext context) async {
    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
        _downloadStatus = 'Memulai download...';
        _currentDownloadUrl = url;
      });

      print("Downloading from: $url");

      // Untuk platform web
      if (kIsWeb) {
        await _downloadFileForWebWithBlob(url, siswa, context);
        return;
      }

      // Untuk platform mobile (kode asli)
      String extension = getFileExtensionFromUrl(url);

      // Request permission untuk mobile
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {

        final String savePath = '/storage/emulated/0/Download/${siswa.nama}$extension';
        final Dio dio = Dio();

        setState(() {
          _downloadStatus = 'Sedang mengunduh...';
        });

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

            }
          },
        );

        // Hapus notifikasi progress dan tampilkan notifikasi sukses
        await NotificationService.cancelProgressNotification(notificationId);
        await NotificationService.showDownloadNotification(
          title: 'Download Berhasil',
          body: 'File ${siswa.nama}$extension berhasil disimpan di Folder Download',
        );

        _showDownloadSuccess(context, 'Data berhasil didownload ke Folder Download');
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
          title: 'Download Gagal',
          body: 'Izin penyimpanan ditolak',
        );

        _showDownloadError(context, 'Izin penyimpanan ditolak');
        print("Storage permission denied");
      }
    } catch (e) {
      // Handle error dengan notifikasi
      await NotificationService.cancelProgressNotification(notificationId);
      await NotificationService.showDownloadNotification(
        title: 'Download Gagal',
        body: 'Terjadi kesalahan: ${e.toString()}',
      );

      _handleDownloadError(context, e);
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  // Method alternatif untuk download di web dengan blob (untuk kasus CORS)
  Future<void> _downloadFileForWebWithBlob(String url, UserModel siswa, BuildContext context) async {
    try {
      setState(() {
        _downloadStatus = 'Mengunduh file...';
      });

      final String extension = getFileExtensionFromUrl(url);
      final String fileName = '${siswa.nama}$extension';

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
      anchorElement.download = fileName;
      anchorElement.style.display = 'none';

      html.document.body?.append(anchorElement);
      anchorElement.click();
      anchorElement.remove();

      // Cleanup
      html.Url.revokeObjectUrl(blobUrl);

      _showDownloadSuccess(context, 'File berhasil didownload');
      print("File downloaded successfully using blob method");

    } catch (e) {
      throw Exception('Gagal download file: $e');
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
    print("Error downloading file: $error");
  }

  // Fungsi helper untuk mendapatkan extension dari URL
  String getFileExtensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final dotIndex = path.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < path.length - 1) {
        return path.substring(dotIndex);
      }
    } catch (e) {
      print("Error parsing URL: $e");
    }
    return '.bin'; // Default extension
  }

  String _formatDateTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Pengumpulan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card - Informasi Siswa
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
                          child: Row(
                            children: [
                              widget.p.profpic != '-'
                                  ? CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(widget.p.profpic),
                                onBackgroundImageError: (exception, stackTrace) {
                                  // Handle error jika gambar tidak bisa dimuat
                                },
                                child: widget.p.profpic.isEmpty ? Icon(Icons.person) : null,
                              )
                                  : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blue.shade700,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.p.nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Siswa Kelas ${widget.p.kelas}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Waktu Pengumpulan
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
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.green.shade700,
                                size: 45,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Waktu Pengumpulan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(widget.p.tugas!.timestamp),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Deskripsi Card
                    if (widget.p.tugas!.deskripsi != '-')
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Deskripsi",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  widget.p.tugas!.deskripsi,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // File Attachments Section
                    Center(
                        child: Text(
                          "File Terlampir",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade800,
                          ),
                        )
                    ),
                    SizedBox(height: 12),

                    // Gambar Card
                    _buildMediaGrid(widget.p.tugas!),

                    // Jika tidak ada file yang dilampirkan
                    if (widget.p.tugas!.linkGambar == '-' &&
                        widget.p.tugas!.linkVideo == '-' &&
                        widget.p.tugas!.linkAudio == '-' &&
                        widget.p.tugas!.linkFile == '-')
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

                    // Section Penilaian
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.grading,
                                    color: Colors.green.shade700,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Penilaian Tugas",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Input Nilai
                              TextFormField(
                                controller: _nilaiController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Nilai (0-100)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(Icons.score),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Masukkan nilai';
                                  }
                                  final nilai = int.tryParse(value);
                                  if (nilai == null || nilai < 0 || nilai > 100) {
                                    return 'Nilai harus antara 0-100';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16),

                              // Tombol Simpan Nilai
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Validasi dan simpan nilai
                                    final nilai = int.tryParse(_nilaiController.text);
                                    if (nilai == null || nilai < 0 || nilai > 100) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Masukkan nilai yang valid (0-100)'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // Proses penyimpanan nilai
                                    _simpanNilai(nilai);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Simpan Nilai',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Spacer untuk memberi ruang bagi progress bar di bawah
                    SizedBox(height: _isDownloading ? 80 : 20),
                  ],
                ),
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
      ),
    );
  }
}