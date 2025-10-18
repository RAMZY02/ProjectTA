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
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:universal_html/html.dart' as html;
import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_event.dart';
import '../models/user_model.dart';
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
                    if (widget.p.tugas!.linkGambar != '-')
                      _buildFileCard(
                        icon: Icons.image,
                        title: "Gambar",
                        subtitle: "File gambar terlampir",
                        color: Colors.orange.shade700,
                        url: widget.p.tugas!.linkGambar,
                      ),

                    // Video Card
                    if (widget.p.tugas!.linkVideo != '-')
                      _buildFileCard(
                        icon: Icons.videocam,
                        title: "Video",
                        subtitle: "File video terlampir",
                        color: Colors.red.shade700,
                        url: widget.p.tugas!.linkVideo,
                      ),

                    // Audio Card
                    if (widget.p.tugas!.linkAudio != '-')
                      _buildFileCard(
                        icon: Icons.audiotrack,
                        title: "Audio",
                        subtitle: "File audio terlampir",
                        color: Colors.purple.shade700,
                        url: widget.p.tugas!.linkAudio,
                      ),

                    // File Card
                    if (widget.p.tugas!.linkFile != '-')
                      _buildFileCard(
                        icon: Icons.insert_drive_file,
                        title: "Dokumen",
                        subtitle: "File dokumen terlampir",
                        color: Colors.blue.shade700,
                        url: widget.p.tugas!.linkFile,
                      ),

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

  Widget _buildFileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String url,
  }) {
    final isDownloadingThisFile = _isDownloading && _currentDownloadUrl == url;
    String extension = getFileExtensionFromUrl(url);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
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
                trailing: isDownloadingThisFile
                    ? Container(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: _downloadProgress / 100,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
                    : IconButton(
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
                  onPressed: () => _downloadFile(url, widget.p, context),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              if(title == 'Video')
                _buildVideoPreview(url),
              if(title == 'Gambar')
                _buildImagePreview(url),
              if(title == 'Audio')
                AudioPreviewWidget(audioUrl: url),
              if(title == 'Dokumen' && extension == '.pdf')
                SizedBox(
                  height: 450, // Atur tinggi sesuai kebutuhan
                  child: _buildFilePreview(url),
                ),
            ],
          )
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
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
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPreview(String videoUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: VideoPlayerWidget(videoUrl: videoUrl),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String pdfUrl) {
    if (pdfUrl.isEmpty || pdfUrl == '-') {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 600,
      ),
      child: SfPdfViewer.network(
        pdfUrl,
        initialZoomLevel: 1.0,
      ),
    );
  }

  Future<void> _downloadFile(String url, UserModel siswa, BuildContext context) async {
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
              final progress = (received / total * 100);
              setState(() {
                _downloadProgress = progress;
                _downloadStatus = '${(received / 1024 / 1024).toStringAsFixed(1)} MB / ${(total / 1024 / 1024).toStringAsFixed(1)} MB';
              });
            }
          },
        );

        _showDownloadSuccess(context, 'Data berhasil didownload ke Folder Download');
        print("File downloaded successfully to: $savePath");

      } else {
        setState(() {
          _isDownloading = false;
          _downloadStatus = 'Izin ditolak';
          _currentDownloadUrl = null;
        });
        _showDownloadError(context, 'Izin penyimpanan ditolak');
        print("Storage permission denied");
      }
    } catch (e) {
      _handleDownloadError(context, e);
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

  // Simulasi progress untuk web (untuk UX yang lebih baik)
  Future<void> _simulateDownloadProgress() async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 150));
      if (_isDownloading) {
        setState(() {
          _downloadProgress = i.toDouble();
          _downloadStatus = i == 100 ? 'Download selesai!' : 'Mengunduh... $i%';
        });
      }
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
}