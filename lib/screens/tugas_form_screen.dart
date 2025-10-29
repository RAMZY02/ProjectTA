import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_state.dart';
import 'package:project_ta/constants/color.dart';
import '../bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import '../bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import '../bloc/tugas/tugas_bloc.dart';
import '../bloc/tugas/tugas_event.dart';
import '../bloc/tugas/tugas_state.dart';
import '../models/tugas_model.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class TugasFormScreen extends StatefulWidget {
  final String token;
  final int userId;
  final TugasModel? tugas;

  const TugasFormScreen({required this.token, required this.userId, this.tugas});

  @override
  _TugasFormScreenState createState() => _TugasFormScreenState();
}

class _TugasFormScreenState extends State<TugasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _kelasController;
  late DateTime _selectedDeadline;

  // State untuk upload file
  bool _isUploadingVideo = false;
  bool _isUploadingGambar = false;
  bool _isUploadingAudio = false;
  bool _isUploadingFile = false;
  String? _uploadErrorVideo;
  String? _uploadErrorGambar;
  String? _uploadErrorAudio;
  String? _uploadErrorFile;
  String? _uploadSuccessVideo;
  String? _uploadSuccessGambar;
  String? _uploadSuccessAudio;
  String? _uploadSuccessFile;

  // Controller untuk link yang diupload
  late TextEditingController _linkVideoController;
  late TextEditingController _linkGambarController;
  late TextEditingController _linkAudioController;
  late TextEditingController _linkFileController;

  final List<String> _kelasOptions = [
    '7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J',
    '8A', '8B', '8C', '8D', '8E', '8F', '8G', '8H', '8I', '8J',
    '9A', '9B', '9C', '9D', '9E', '9F', '9G', '9H', '9I', '9J'
  ];

  int tahunPelajaran = 1;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.tugas?.nama ?? '');
    _deskripsiController = TextEditingController(text: widget.tugas?.deskripsi ?? '');
    _kelasController = TextEditingController(text: widget.tugas?.kelas ?? '');
    _selectedDeadline = widget.tugas?.deadline ?? DateTime.now().add(Duration(days: 7));

    // Inisialisasi controller untuk link
    _linkVideoController = TextEditingController(text: widget.tugas?.linkVideo ?? '');
    _linkGambarController = TextEditingController(text: widget.tugas?.linkGambar ?? '');
    _linkAudioController = TextEditingController(text: widget.tugas?.linkAudio ?? '');
    _linkFileController = TextEditingController(text: widget.tugas?.linkFile ?? '');

    final authState = context.read<AuthBloc>().state;
    if(authState is Authenticated){
      context.read<TahunPelajaranBloc>().add(FetchAllTahunPelajaran(token: authState.token));
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _kelasController.dispose();
    _linkVideoController.dispose();
    _linkGambarController.dispose();
    _linkAudioController.dispose();
    _linkFileController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    // Pertama pilih tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Kemudian pilih waktu
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
      );

      if (pickedTime != null) {
        // Gabungkan tanggal dan waktu yang dipilih
        final DateTime newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDeadline = newDateTime;
        });
      }
    }
  }

  // Fungsi untuk upload file berdasarkan jenis
  Future<void> _uploadFile(String fileType, AuthState authState) async {
    if (authState is! Authenticated) return;

    FileType pickerType;
    String contentType;
    String folder;

    switch (fileType) {
      case 'video':
        pickerType = FileType.video;
        contentType = 'video/mp4';
        folder = 'Tugas/Video';
        break;
      case 'gambar':
        pickerType = FileType.image;
        contentType = 'image/jpeg';
        folder = 'Tugas/Gambar';
        break;
      case 'audio':
        pickerType = FileType.audio;
        contentType = 'audio/mpeg';
        folder = 'Tugas/Audio';
        break;
      case 'file':
        pickerType = FileType.any;
        contentType = 'application/octet-stream';
        folder = 'Tugas/File';
        break;
      default:
        return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: pickerType,
        allowMultiple: false,
      );

      if (result != null) {
        // Update state untuk menunjukkan sedang upload
        _setUploadingState(fileType, true);

        // Handle untuk platform web
        if (kIsWeb) {
          await _handleWebUpload(result.files.single, fileType, folder, contentType, authState);
        } else {
          // Handle untuk platform mobile
          await _handleMobileUpload(result.files.single, fileType, folder, contentType, authState);
        }
      }
    } catch (e) {
      _setUploadErrorState(fileType, 'Gagal memilih file: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload di web
  Future<void> _handleWebUpload(
      PlatformFile platformFile,
      String fileType,
      String folder,
      String contentType,
      Authenticated authState,
      ) async {
    try {
      // Validasi file untuk web
      if (platformFile.bytes == null) {
        _setUploadErrorState(fileType, 'Tidak dapat membaca file');
        return;
      }

      // Tentukan content type berdasarkan nama file
      final actualContentType = _getContentTypeFromFileName(platformFile.name, fileType, contentType);

      // Dapatkan extension file yang tepat
      final fileExtension = _getFileExtensionForWeb(platformFile.name, fileType);

      // Generate filename
      final fileName = '$folder/${_namaController.text}-${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Upload file menggunakan CloudflareBloc untuk web
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileWeb: platformFile.bytes, // Gunakan bytes untuk web
          contentType: actualContentType,
          token: authState.token,
        ),
      );

      // Tampilkan feedback sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File $fileType berhasil diupload')),
      );

    } catch (e) {
      _setUploadErrorState(fileType, 'Gagal upload file: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload di mobile
  Future<void> _handleMobileUpload(
      PlatformFile platformFile,
      String fileType,
      String folder,
      String contentType,
      Authenticated authState,
      ) async {
    try {
      // Validasi path file untuk mobile
      if (platformFile.path == null) {
        _setUploadErrorState(fileType, 'Tidak dapat mengakses file');
        return;
      }

      File file = File(platformFile.path!);

      // Tentukan content type berdasarkan extension file
      final actualContentType = _getContentTypeFromFileName(file.path, fileType, contentType);

      // Generate filename
      final fileName = '$folder/${_namaController.text}-${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(file.path)}';

      // Upload file menggunakan CloudflareBloc untuk mobile
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileContent: file, // Gunakan File untuk mobile
          contentType: actualContentType,
          token: authState.token,
        ),
      );

    } catch (e) {
      _setUploadErrorState(fileType, 'Gagal upload file: ${e.toString()}');
    }
  }

  // Helper function untuk menentukan content type berdasarkan nama file
  String _getContentTypeFromFileName(String fileName, String fileType, String defaultType) {
    final lowerFileName = fileName.toLowerCase();

    // Deteksi berdasarkan extension file
    if (lowerFileName.endsWith('.png')) {
      return 'image/png';
    } else if (lowerFileName.endsWith('.jpg') || lowerFileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lowerFileName.endsWith('.gif')) {
      return 'image/gif';
    } else if (lowerFileName.endsWith('.webp')) {
      return 'image/webp';
    } else if (lowerFileName.endsWith('.mp4')) {
      return 'video/mp4';
    } else if (lowerFileName.endsWith('.mov')) {
      return 'video/quicktime';
    } else if (lowerFileName.endsWith('.avi')) {
      return 'video/x-msvideo';
    } else if (lowerFileName.endsWith('.webm')) {
      return 'video/webm';
    } else if (lowerFileName.endsWith('.mkv')) {
      return 'video/x-matroska';
    } else if (lowerFileName.endsWith('.mp3')) {
      return 'audio/mpeg';
    } else if (lowerFileName.endsWith('.wav')) {
      return 'audio/wav';
    } else if (lowerFileName.endsWith('.ogg')) {
      return 'audio/ogg';
    } else if (lowerFileName.endsWith('.pdf')) {
      return 'application/pdf';
    } else if (lowerFileName.endsWith('.doc')) {
      return 'application/msword';
    } else if (lowerFileName.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (lowerFileName.endsWith('.xls')) {
      return 'application/vnd.ms-excel';
    } else if (lowerFileName.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    } else if (lowerFileName.endsWith('.zip')) {
      return 'application/zip';
    } else if (lowerFileName.endsWith('.rar')) {
      return 'application/x-rar-compressed';
    }

    // Fallback ke default type berdasarkan fileType
    return defaultType;
  }

  // Helper function untuk mendapatkan extension file di web
  String _getFileExtensionForWeb(String fileName, String fileType) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex).toLowerCase();
    }

    // Default extension berdasarkan fileType jika tidak ada extension
    switch (fileType) {
      case 'video':
        return '.mp4';
      case 'gambar':
        return '.jpg';
      case 'audio':
        return '.mp3';
      case 'file':
        return '.bin';
      default:
        return '.bin';
    }
  }

  // Helper function untuk mendapatkan extension file (untuk mobile)
  String _getFileExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      return filePath.substring(dotIndex).toLowerCase();
    }
    return '';
  }

  // Helper function untuk set uploading state
  void _setUploadingState(String fileType, bool isUploading) {
    setState(() {
      // Sesuaikan dengan state management yang ada di widget Anda
      // Contoh:
      if (fileType == 'video') _isUploadingVideo = isUploading;
      if (fileType == 'gambar') _isUploadingGambar = isUploading;
      if (fileType == 'audio') _isUploadingAudio = isUploading;
      if (fileType == 'file') _isUploadingFile = isUploading;
    });
  }

  // Helper function untuk set error state
  void _setUploadErrorState(String fileType, String errorMessage) {
    setState(() {
      // Reset state upload sesuai fileType
      _setUploadingState(fileType, false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _setUploadSuccessState(String fileType, String link) {
    setState(() {
      switch (fileType) {
        case 'video':
          _isUploadingVideo = false;
          _linkVideoController.text = link;
          _uploadSuccessVideo = 'Upload berhasil!';
          break;
        case 'gambar':
          _isUploadingGambar = false;
          _linkGambarController.text = link;
          _uploadSuccessGambar = 'Upload berhasil!';
          break;
        case 'audio':
          _isUploadingAudio = false;
          _linkAudioController.text = link;
          _uploadSuccessAudio = 'Upload berhasil!';
          break;
        case 'file':
          _isUploadingFile = false;
          _linkFileController.text = link;
          _uploadSuccessFile = 'Upload berhasil!';
          break;
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.tugas == null) {
        // Create new tugas
        context.read<TugasBloc>().add(CreateTugas(
          token: widget.token,
          idUser: widget.userId,
          nama: _namaController.text,
          deskripsi: _deskripsiController.text,
          kelas: _kelasController.text,
          linkVideo: _linkVideoController.text.isNotEmpty ? _linkVideoController.text : '-',
          linkGambar: _linkGambarController.text.isNotEmpty ? _linkGambarController.text : '-',
          linkAudio: _linkAudioController.text.isNotEmpty ? _linkAudioController.text : '-',
          linkFile: _linkFileController.text.isNotEmpty ? _linkFileController.text : '-',
          deadline: _selectedDeadline,
          id_tahun_pelajaran: tahunPelajaran
        ));
      } else {
        // Update existing tugas
        context.read<TugasBloc>().add(UpdateTugas(
          token: widget.token,
          tugasId: widget.tugas!.id,
          nama: _namaController.text,
          deskripsi: _deskripsiController.text,
          kelas: _kelasController.text,
          linkVideo: _linkVideoController.text.isNotEmpty ? _linkVideoController.text : '-',
          linkGambar: _linkGambarController.text.isNotEmpty ? _linkGambarController.text : '-',
          linkAudio: _linkAudioController.text.isNotEmpty ? _linkAudioController.text : '-',
          linkFile: _linkFileController.text.isNotEmpty ? _linkFileController.text : '-',
          deadline: _selectedDeadline,
        ));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return SafeArea(
      child: BlocListener<CloudflareBloc, CloudflareState>(
        listener: (context, state) {
          if (state is CloudFlareLoaded) {
            // Determine file type based on file name or other logic
            String fileType = 'file';
            if (state.fileName.contains('Video')) fileType = 'video';
            if (state.fileName.contains('Gambar')) fileType = 'gambar';
            if (state.fileName.contains('Audio')) fileType = 'audio';

            _setUploadSuccessState(fileType, 'https://edukasiin.animein.net/${state.fileName}');
          } else if (state is CloudFlareError) {
            // Handle error (you might need to track which file was being uploaded)
            _setUploadErrorState('file', state.message);
          }
        },
        child: BlocListener<TugasBloc, TugasState>(
          listener: (context, state) {
            if (state is TugasOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is TugasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocListener<TahunPelajaranBloc, TahunPelajaranState>(
            listener: (context, state){
              if(state is TahunPelajaranLoaded){
                final currentTahunPelajaran = state.tahunPelajaranList.last;
                tahunPelajaran = currentTahunPelajaran.id;
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.tugas == null ? 'Buat Tugas' : 'Edit Tugas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                backgroundColor: kPrimaryColor,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.grey,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              body: BlocBuilder<TugasBloc, TugasState>(
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _namaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Tugas',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan nama tugas';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _deskripsiController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan deskripsi';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _kelasController.text.isNotEmpty ? _kelasController.text : null,
                            decoration: InputDecoration(
                              labelText: 'Kelas',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            menuMaxHeight: 200, // Alternatif lain (beberapa versi Flutter)
                            isExpanded: true, // Agar dropdown mengisi lebar parent
                            style: TextStyle(fontSize: 16, color:  Colors.black), // Style untuk teks yang dipilih
                            iconSize: 24, // Ukuran icon dropdown
                            items: _kelasOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 16, color: Colors.black), // Style untuk item dropdown
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _kelasController.text = newValue ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap pilih kelas';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: _selectDeadline,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Deadline',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: Icon(Icons.calendar_today),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                controller: TextEditingController(
                                  text: '${_selectedDeadline.day.toString().padLeft(2, '0')}/${_selectedDeadline.month.toString().padLeft(2, '0')}/${_selectedDeadline.year} ${_selectedDeadline.hour.toString().padLeft(2, '0')}:${_selectedDeadline.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Section untuk Upload Video
                          _buildUploadSection(
                            title: 'Video',
                            controller: _linkVideoController,
                            isUploading: _isUploadingVideo,
                            error: _uploadErrorVideo,
                            success: _uploadSuccessVideo,
                            fileType: 'video',
                            authState: authState,
                          ),
                          SizedBox(height: 16),

                          // Section untuk Upload Gambar
                          _buildUploadSection(
                            title: 'Gambar',
                            controller: _linkGambarController,
                            isUploading: _isUploadingGambar,
                            error: _uploadErrorGambar,
                            success: _uploadSuccessGambar,
                            fileType: 'gambar',
                            authState: authState,
                          ),
                          SizedBox(height: 16),

                          // Section untuk Upload Audio
                          _buildUploadSection(
                            title: 'Audio',
                            controller: _linkAudioController,
                            isUploading: _isUploadingAudio,
                            error: _uploadErrorAudio,
                            success: _uploadSuccessAudio,
                            fileType: 'audio',
                            authState: authState,
                          ),
                          SizedBox(height: 16),

                          // Section untuk Upload File
                          _buildUploadSection(
                            title: 'File',
                            controller: _linkFileController,
                            isUploading: _isUploadingFile,
                            error: _uploadErrorFile,
                            success: _uploadSuccessFile,
                            fileType: 'file',
                            authState: authState,
                          ),
                          SizedBox(height: 24),

                          state is TugasLoading
                              ? Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.tugas == null ? 'Buat Tugas' : 'Update Tugas',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _buildUploadSection({
    required String title,
    required TextEditingController controller,
    required bool isUploading,
    required String? error,
    required String? success,
    required String fileType,
    required AuthState authState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload $title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Link $title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          readOnly: true,
        ),
        SizedBox(height: 8),
        if (isUploading)
          Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Mengupload $title...'),
            ],
          ),
        ElevatedButton(
          onPressed: isUploading
              ? null
              : () {
            if (_namaController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Harap isi nama tugas terlebih dahulu'),
                ),
              );
              return;
            }
            _uploadFile(fileType, authState);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[50],
            foregroundColor: kPrimaryColor,
          ),
          child: Text('Pilih $title'),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              error,
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (success != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              success,
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }
}