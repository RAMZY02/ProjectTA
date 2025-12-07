import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_bloc.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_event.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_state.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import 'package:project_ta/bloc/tahun_pelajaran/tahun_pelajaran_state.dart';
import 'package:project_ta/bloc/tugas/tugas_bloc.dart';
import 'package:project_ta/bloc/tugas/tugas_event.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/models/tahun_pelajaran_model.dart';
import 'package:project_ta/models/tugas_model.dart';
import 'package:project_ta/models/user_model.dart';

import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_state.dart';

class InsertTugasAdminScreen extends StatefulWidget {
  final TugasModel? tugasData;
  final UserModel? guruData;
  final bool isEdit;

  const InsertTugasAdminScreen({
    super.key,
    this.tugasData,
    this.guruData,
    this.isEdit = false,
  });

  @override
  State<InsertTugasAdminScreen> createState() => _InsertTugasAdminScreenState();
}

class _InsertTugasAdminScreenState extends State<InsertTugasAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _kelasController;
  late TextEditingController _linkVideoController;
  late TextEditingController _linkGambarController;
  late TextEditingController _linkAudioController;
  late TextEditingController _linkFileController;
  late TextEditingController _deadlineController;

  final List<String> _kelasOptions = [
    '7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J',
    '8A', '8B', '8C', '8D', '8E', '8F', '8G', '8H', '8I', '8J',
    '9A', '9B', '9C', '9D', '9E', '9F', '9G', '9H', '9I', '9J'
  ];

  // State variables for file uploads
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

  // Variables for selection
  DateTime? _selectedDeadline;
  int? _selectedTahunPelajaranId;
  UserModel? _selectedGuru;

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(
      text: widget.tugasData?.nama ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.tugasData?.deskripsi ?? '',
    );
    _kelasController = TextEditingController(
      text: widget.tugasData?.kelas ?? '',
    );
    _linkVideoController = TextEditingController(
      text: widget.tugasData?.linkVideo ?? '',
    );
    _linkGambarController = TextEditingController(
      text: widget.tugasData?.linkGambar ?? '',
    );
    _linkAudioController = TextEditingController(
      text: widget.tugasData?.linkAudio ?? '',
    );
    _linkFileController = TextEditingController(
      text: widget.tugasData?.linkFile ?? '',
    );
    _deadlineController = TextEditingController(
      text: widget.tugasData?.deadline != null
          ? _formatDate(widget.tugasData!.deadline)
          : '',
    );

    if (widget.isEdit) {
      _selectedDeadline = widget.tugasData!.deadline;
      _selectedTahunPelajaranId = widget.tugasData?.idTahunPelajaran;
      _selectedGuru = widget.guruData ?? null; // Set guru dari data existing untuk edit
    }

    // Fetch tahun pelajaran dan data guru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTahunPelajaran();
      _fetchGuruData();
    });
  }

  void _fetchTahunPelajaran() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<TahunPelajaranBloc>().add(
          FetchAllTahunPelajaran(token: authState.token));
    }
  }

  void _fetchGuruData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<UsersBloc>().add(
          FetchUsersByRoleGuru(token: authState.token));
    }
  }

  int? _getLatestTahunPelajaranId(List<TahunPelajaranModel> tahunPelajaranList) {
    if (tahunPelajaranList.isEmpty) return null;

    // Urutkan berdasarkan ID descending dan ambil yang terbaru
    tahunPelajaranList.sort((a, b) => b.id.compareTo(a.id));
    return tahunPelajaranList.first.id;
  }

  String _getTahunPelajaranText(List<TahunPelajaranModel> tahunPelajaranList) {
    if (tahunPelajaranList.isEmpty) return 'Tidak ada data tahun pelajaran';

    final latestTahunPelajaran = tahunPelajaranList.last;

    return '${latestTahunPelajaran.tahun} - Semester ${latestTahunPelajaran.semester}';
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
    _deadlineController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(date);
    } catch (e) {
      return DateFormat('dd-MM-yyyy').format(date);
    }
  }

  // Fungsi untuk upload file berdasarkan jenis
  Future<void> _uploadFile(String fileType, AuthState authState) async {
    if (authState is! Authenticated) return;

    if (_namaController.text.isEmpty || _kelasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi nama tugas dan kelas terlebih dahulu'),
        ),
      );
      return;
    }

    FileType pickerType;
    String contentType;
    String folder;
    List<String> allowedExtensions;

    switch (fileType) {
      case 'video':
        pickerType = FileType.video;
        contentType = 'video/mp4';
        folder = 'Tugas/Video/';
        allowedExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
        break;
      case 'gambar':
        pickerType = FileType.image;
        contentType = 'image/jpeg';
        folder = 'Tugas/Gambar/';
        allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
        break;
      case 'audio':
        pickerType = FileType.audio;
        contentType = 'audio/mpeg';
        folder = 'Tugas/Audio/';
        allowedExtensions = ['mp3', 'wav', 'ogg', 'm4a', 'aac'];
        break;
      case 'file':
        pickerType = FileType.any;
        contentType = 'application/octet-stream';
        folder = 'Tugas/File/';
        allowedExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip'];
        break;
      default:
        return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: pickerType,
        allowMultiple: false,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        // Update state untuk menunjukkan sedang upload
        _setUploadingState(fileType, true);

        // Handle untuk platform web
        if (kIsWeb) {
          await _handleWebFileUpload(
            result.files.single,
            fileType,
            folder,
            contentType,
            authState,
          );
        } else {
          // Handle untuk platform mobile
          await _handleMobileFileUpload(
            result.files.single,
            fileType,
            folder,
            contentType,
            authState,
          );
        }
      }
    } catch (e) {
      _setUploadErrorState(fileType, 'Gagal memilih file: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload file di web
  Future<void> _handleWebFileUpload(
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

      // Tentukan content type berdasarkan nama file untuk web
      final actualContentType = _getContentTypeForWeb(platformFile.name, fileType, contentType);

      // Generate filename untuk web
      final fileExtension = _getFileExtensionForWeb(platformFile.name, fileType);
      final fileName = '$folder${_kelasController.text}-${_namaController.text}-${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Upload file menggunakan CloudflareBloc untuk web
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileWeb: platformFile.bytes, // Gunakan bytes untuk web
          contentType: actualContentType,
          token: authState.token,
        ),
      );

    } catch (e) {
      _setUploadErrorState(fileType, 'Gagal upload file: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload file di mobile
  Future<void> _handleMobileFileUpload(
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

      // Tentukan content type berdasarkan extension file untuk mobile
      final actualContentType = _getContentTypeForMobile(file.path, fileType, contentType);

      // Generate filename untuk mobile
      final fileName = '$folder${_kelasController.text}-${_namaController.text}-${DateTime.now().millisecondsSinceEpoch}${_extension(file.path)}';

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

  // Helper function untuk menentukan content type di web
  String _getContentTypeForWeb(String fileName, String fileType, String defaultType) {
    final lowerFileName = fileName.toLowerCase();

    // Deteksi berdasarkan extension file
    if (fileType == 'gambar') {
      if (lowerFileName.endsWith('.png')) {
        return 'image/png';
      } else if (lowerFileName.endsWith('.jpg') || lowerFileName.endsWith('.jpeg')) {
        return 'image/jpeg';
      } else if (lowerFileName.endsWith('.gif')) {
        return 'image/gif';
      } else if (lowerFileName.endsWith('.webp')) {
        return 'image/webp';
      } else if (lowerFileName.endsWith('.bmp')) {
        return 'image/bmp';
      }
    } else if (fileType == 'video') {
      if (lowerFileName.endsWith('.mp4')) {
        return 'video/mp4';
      } else if (lowerFileName.endsWith('.mov')) {
        return 'video/quicktime';
      } else if (lowerFileName.endsWith('.avi')) {
        return 'video/x-msvideo';
      } else if (lowerFileName.endsWith('.webm')) {
        return 'video/webm';
      } else if (lowerFileName.endsWith('.mkv')) {
        return 'video/x-matroska';
      }
    } else if (fileType == 'audio') {
      if (lowerFileName.endsWith('.mp3')) {
        return 'audio/mpeg';
      } else if (lowerFileName.endsWith('.wav')) {
        return 'audio/wav';
      } else if (lowerFileName.endsWith('.ogg')) {
        return 'audio/ogg';
      } else if (lowerFileName.endsWith('.m4a')) {
        return 'audio/mp4';
      } else if (lowerFileName.endsWith('.aac')) {
        return 'audio/aac';
      }
    } else if (fileType == 'file') {
      if (lowerFileName.endsWith('.pdf')) {
        return 'application/pdf';
      } else if (lowerFileName.endsWith('.doc')) {
        return 'application/msword';
      } else if (lowerFileName.endsWith('.docx')) {
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else if (lowerFileName.endsWith('.xls')) {
        return 'application/vnd.ms-excel';
      } else if (lowerFileName.endsWith('.xlsx')) {
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (lowerFileName.endsWith('.ppt')) {
        return 'application/vnd.ms-powerpoint';
      } else if (lowerFileName.endsWith('.pptx')) {
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      } else if (lowerFileName.endsWith('.txt')) {
        return 'text/plain';
      } else if (lowerFileName.endsWith('.zip')) {
        return 'application/zip';
      }
    }

    // Fallback ke default type
    return defaultType;
  }

  // Helper function untuk menentukan content type di mobile
  String _getContentTypeForMobile(String filePath, String fileType, String defaultType) {
    final lowerFilePath = filePath.toLowerCase();

    // Deteksi berdasarkan extension file
    if (fileType == 'gambar') {
      if (lowerFilePath.endsWith('.png')) {
        return 'image/png';
      } else if (lowerFilePath.endsWith('.jpg') || lowerFilePath.endsWith('.jpeg')) {
        return 'image/jpeg';
      } else if (lowerFilePath.endsWith('.gif')) {
        return 'image/gif';
      } else if (lowerFilePath.endsWith('.webp')) {
        return 'image/webp';
      } else if (lowerFilePath.endsWith('.bmp')) {
        return 'image/bmp';
      }
    } else if (fileType == 'video') {
      if (lowerFilePath.endsWith('.mp4')) {
        return 'video/mp4';
      } else if (lowerFilePath.endsWith('.mov')) {
        return 'video/quicktime';
      } else if (lowerFilePath.endsWith('.avi')) {
        return 'video/x-msvideo';
      } else if (lowerFilePath.endsWith('.mkv')) {
        return 'video/x-matroska';
      }
    } else if (fileType == 'audio') {
      if (lowerFilePath.endsWith('.mp3')) {
        return 'audio/mpeg';
      } else if (lowerFilePath.endsWith('.wav')) {
        return 'audio/wav';
      } else if (lowerFilePath.endsWith('.ogg')) {
        return 'audio/ogg';
      } else if (lowerFilePath.endsWith('.m4a')) {
        return 'audio/mp4';
      } else if (lowerFilePath.endsWith('.aac')) {
        return 'audio/aac';
      }
    } else if (fileType == 'file') {
      if (lowerFilePath.endsWith('.pdf')) {
        return 'application/pdf';
      } else if (lowerFilePath.endsWith('.doc')) {
        return 'application/msword';
      } else if (lowerFilePath.endsWith('.docx')) {
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else if (lowerFilePath.endsWith('.xls')) {
        return 'application/vnd.ms-excel';
      } else if (lowerFilePath.endsWith('.xlsx')) {
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (lowerFilePath.endsWith('.ppt')) {
        return 'application/vnd.ms-powerpoint';
      } else if (lowerFilePath.endsWith('.pptx')) {
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      } else if (lowerFilePath.endsWith('.txt')) {
        return 'text/plain';
      } else if (lowerFilePath.endsWith('.zip')) {
        return 'application/zip';
      }
    }

    // Fallback ke default type
    return defaultType;
  }

  // Helper function untuk mendapatkan extension file di web
  String _getFileExtensionForWeb(String fileName, String fileType) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      final extension = fileName.substring(dotIndex).toLowerCase();
      return extension;
    }

    // Default extension berdasarkan fileType jika tidak ada extension yang valid
    switch (fileType) {
      case 'video':
        return '.mp4';
      case 'gambar':
        return '.jpg';
      case 'audio':
        return '.mp3';
      case 'file':
        return '.pdf';
      default:
        return '.bin';
    }
  }

  // Helper function untuk mendapatkan extension file (untuk mobile)
  String _extension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      return filePath.substring(dotIndex).toLowerCase();
    }
    return '';
  }

  // Helper functions untuk mengatur state upload
  void _setUploadingState(String fileType, bool isUploading) {
    setState(() {
      switch (fileType) {
        case 'video':
          _isUploadingVideo = isUploading;
          _uploadErrorVideo = null;
          break;
        case 'gambar':
          _isUploadingGambar = isUploading;
          _uploadErrorGambar = null;
          break;
        case 'audio':
          _isUploadingAudio = isUploading;
          _uploadErrorAudio = null;
          break;
        case 'file':
          _isUploadingFile = isUploading;
          _uploadErrorFile = null;
          break;
      }
    });
  }

  void _setUploadErrorState(String fileType, String error) {
    setState(() {
      switch (fileType) {
        case 'video':
          _isUploadingVideo = false;
          _uploadErrorVideo = error;
          break;
        case 'gambar':
          _isUploadingGambar = false;
          _uploadErrorGambar = error;
          break;
        case 'audio':
          _isUploadingAudio = false;
          _uploadErrorAudio = error;
          break;
        case 'file':
          _isUploadingFile = false;
          _uploadErrorFile = error;
          break;
      }
    });
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

  // Widget untuk menampilkan field upload dengan tombol
  Widget _buildUploadField({
    required String label,
    required String fileType,
    required TextEditingController controller,
    required bool isUploading,
    required String? uploadError,
    required String? uploadSuccess,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '$label (Opsional)',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          readOnly: true,
        ),
        const SizedBox(height: 8),
        if (isUploading)
          Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text('Uploading $label...'),
            ],
          ),
        ElevatedButton(
          onPressed: isUploading ? null : () {
            final authState = context.read<AuthBloc>().state;
            _uploadFile(fileType, authState);
          },
          child: Text('Upload $label'),
        ),
        if (uploadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              uploadError,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (uploadSuccess != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                uploadSuccess,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget untuk dropdown guru
  Widget _buildGuruDropdown(List<UserModel> guruList) {
    return DropdownButtonFormField<UserModel>(
      value: _selectedGuru,
      decoration: const InputDecoration(
        labelText: 'Pilih Guru',
        border: OutlineInputBorder(),
        hintText: 'Pilih guru yang bertanggung jawab',
      ),
      items: [
        const DropdownMenuItem<UserModel>(
          value: null,
          child: Text('Pilih Guru'),
        ),
        ...guruList.map((guru) {
          return DropdownMenuItem<UserModel>(
            value: guru,
            child: Text('${guru.nama} (${guru.email})'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGuru = value;
          if (value != null) {
            final selectedGuru = guruList.firstWhere(
                  (guru) => guru.id == value.id,
              orElse: () => guruList.first,
            );
          }
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Harap pilih guru terlebih dahulu';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Tugas' : 'Tambah Tugas'),
      ),
      body: SafeArea(
        child: BlocListener<CloudflareBloc, CloudflareState>(
          listener: (context, state) {
            if (state is CloudFlareLoaded) {
              // Determine file type based on folder name
              String fileType = 'file';
              if (state.fileName.contains('Video/')) {
                fileType = 'video';
              } else if (state.fileName.contains('Gambar/')) {
                fileType = 'gambar';
              } else if (state.fileName.contains('Audio/')) {
                fileType = 'audio';
              } else if (state.fileName.contains('File/')) {
                fileType = 'file';
              }

              _setUploadSuccessState(fileType, 'https://edukasiin.animein.net/${state.fileName}');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('File $fileType berhasil diupload')),
              );
            } else if (state is CloudFlareError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload gagal: ${state.message}')),
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan nama tugas',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tugas tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Guru
                    BlocBuilder<UsersBloc, UsersState>(
                      builder: (context, usersState) {
                        if (usersState is UsersLoading) {
                          return const CircularProgressIndicator();
                        } else if (usersState is UsersLoaded) {
                          final guruList = usersState.users.where((user) => user.role == 'guru').toList();

                          if(_selectedGuru != null){
                            _selectedGuru = usersState.users.firstWhere((test) => test.id == _selectedGuru!.id);
                          }

                          if (guruList.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Tidak ada data guru tersedia'),
                            );
                          }

                          return _buildGuruDropdown(guruList);
                        } else if (usersState is UsersError) {
                          return Text('Error: ${usersState.message}');
                        } else {
                          return const Text('Memuat data guru...');
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _kelasController.text.isNotEmpty ? _kelasController.text : null,
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        border: OutlineInputBorder(),
                      ),
                      menuMaxHeight: 200,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      iconSize: 24,
                      items: _kelasOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
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
                    const SizedBox(height: 16),

                    // Tahun Pelajaran Display
                    BlocBuilder<TahunPelajaranBloc, TahunPelajaranState>(
                      builder: (context, tahunPelajaranState) {
                        if (tahunPelajaranState is TahunPelajaranLoaded) {
                          final tahunPelajaranList = tahunPelajaranState.tahunPelajaranList;
                          final latestId = _getLatestTahunPelajaranId(tahunPelajaranList);
                          final displayText = _getTahunPelajaranText(tahunPelajaranList);

                          // Set the selected tahun pelajaran ID
                          if (!widget.isEdit) {
                            _selectedTahunPelajaranId = latestId;
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[50],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tahun Pelajaran',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (latestId != null)
                                  Text(
                                    'ID: $latestId',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        } else if (tahunPelajaranState is TahunPelajaranError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.red[50],
                            ),
                            child: Text(
                              'Error: ${tahunPelajaranState.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[50],
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Memuat data tahun pelajaran...'),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Tugas',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan deskripsi tugas',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Upload Fields dengan tombol
                    _buildUploadField(
                      label: 'Video',
                      fileType: 'video',
                      controller: _linkVideoController,
                      isUploading: _isUploadingVideo,
                      uploadError: _uploadErrorVideo,
                      uploadSuccess: _uploadSuccessVideo,
                    ),

                    _buildUploadField(
                      label: 'Gambar',
                      fileType: 'gambar',
                      controller: _linkGambarController,
                      isUploading: _isUploadingGambar,
                      uploadError: _uploadErrorGambar,
                      uploadSuccess: _uploadSuccessGambar,
                    ),

                    _buildUploadField(
                      label: 'Audio',
                      fileType: 'audio',
                      controller: _linkAudioController,
                      isUploading: _isUploadingAudio,
                      uploadError: _uploadErrorAudio,
                      uploadSuccess: _uploadSuccessAudio,
                    ),

                    _buildUploadField(
                      label: 'File',
                      fileType: 'file',
                      controller: _linkFileController,
                      isUploading: _isUploadingFile,
                      uploadError: _uploadErrorFile,
                      uploadSuccess: _uploadSuccessFile,
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deadlineController,
                      decoration: const InputDecoration(
                        labelText: 'Deadline Tugas',
                        border: OutlineInputBorder(),
                        hintText: 'DD-MM-YYYY',
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            _deadlineController.text = _formatDate(date);
                            _selectedDeadline = date;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deadline tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Additional validation for required fields
                          if (_selectedDeadline == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Deadline belum dipilih')),
                            );
                            return;
                          }

                          if (_selectedTahunPelajaranId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tahun pelajaran tidak tersedia')),
                            );
                            return;
                          }

                          if (_selectedGuru == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harap pilih guru terlebih dahulu')),
                            );
                            return;
                          }

                          if (authState is Authenticated) {
                            if (!widget.isEdit) {
                              // Create new tugas dengan id guru yang dipilih
                              context.read<TugasBloc>().add(CreateTugas(
                                token: authState.token,
                                idUser: _selectedGuru!.id, // Gunakan ID guru yang dipilih
                                idMapel: _selectedGuru!.id_mapel,
                                nama: _namaController.text,
                                deskripsi: _deskripsiController.text,
                                kelas: _kelasController.text,
                                linkVideo: _linkVideoController.text,
                                linkGambar: _linkGambarController.text,
                                linkAudio: _linkAudioController.text,
                                linkFile: _linkFileController.text,
                                deadline: _selectedDeadline!,
                                id_tahun_pelajaran: _selectedTahunPelajaranId!,
                              ));
                            } else {
                              // Update existing tugas
                              context.read<TugasBloc>().add(UpdateTugas(
                                token: authState.token,
                                tugasId: widget.tugasData!.id,
                                nama: _namaController.text,
                                deskripsi: _deskripsiController.text,
                                kelas: _kelasController.text,
                                linkVideo: _linkVideoController.text,
                                linkGambar: _linkGambarController.text,
                                linkAudio: _linkAudioController.text,
                                linkFile: _linkFileController.text,
                                deadline: _selectedDeadline!,
                              ));
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.isEdit
                                      ? 'Tugas berhasil diperbarui'
                                      : 'Tugas berhasil ditambahkan',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Anda harus login terlebih dahulu')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(widget.isEdit ? 'Update Tugas' : 'Simpan Tugas'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}