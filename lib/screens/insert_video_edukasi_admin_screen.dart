import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
import '../bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import '../bloc/mata_pelajaran/mata_pelajaran_event.dart';
import '../bloc/mata_pelajaran/mata_pelajaran_state.dart';

class InsertVideoEdukasiAdminScreen extends StatefulWidget {
  final VideoEdukasiModel? videoData;

  bool get isEdit => videoData != null;

  const InsertVideoEdukasiAdminScreen({
    super.key,
    this.videoData
  });

  @override
  State<InsertVideoEdukasiAdminScreen> createState() => _InsertVideoEdukasiAdminScreenState();
}

class _InsertVideoEdukasiAdminScreenState extends State<InsertVideoEdukasiAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _linkController;
  late TextEditingController _thumbnailController;
  late TextEditingController _deskripsiController;
  late String _selectedKelas;
  int? _selectedMapelId;
  String? _selectedMapelName;

  bool _isUploading = false;
  bool _isUploadingGambar = false;
  String? _uploadError;
  String? _uploadErrorGambar;
  String? _uploadSuccess;
  String? _uploadSuccessGambar;
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    // Fetch mata pelajaran data
    if (authState is Authenticated) {
      context.read<MataPelajaranBloc>().add(FetchAllMataPelajaran(token: authState.token));
    }

    _judulController = TextEditingController(text: widget.videoData?.judul ?? '');
    _linkController = TextEditingController(
      text: widget.videoData?.link_video ?? '',
    );
    _thumbnailController = TextEditingController(
        text: widget.videoData?.thumbnail ?? ''
    );
    _deskripsiController = TextEditingController(text: widget.videoData?.deskripsi ?? '');
    _selectedKelas = widget.videoData?.kelas ?? '7';

    // Initialize selected mapel for edit mode
    if (widget.isEdit) {
      _selectedMapelId = widget.videoData?.id_mapel;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _linkController.dispose();
    _thumbnailController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // Fungsi untuk upload file berdasarkan jenis
  Future<void> _uploadFile(String fileType, AuthState authState) async {
    if (authState is! Authenticated) return;
    if (_selectedMapelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih mata pelajaran terlebih dahulu')),
      );
      return;
    }

    context.read<VideoEdukasiBloc>().add(LastId(token: authState.token));

    FileType pickerType;
    String contentType;
    String folder;

    switch (fileType) {
      case 'video':
        pickerType = FileType.video;
        contentType = 'video/mp4';
        folder = 'VideoEdukasi/';
        break;
      case 'gambar':
        pickerType = FileType.image;
        contentType = 'image/jpeg';
        folder = 'Thumbnail/';
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

        final videoState = context.read<VideoEdukasiBloc>().state;

        if (videoState is VideoId) {
          // Handle untuk platform web
          if (kIsWeb) {
            await _handleWebFileUpload(
              result.files.single,
              fileType,
              folder,
              contentType,
              authState,
              videoState.IdVideo,
            );
          } else {
            // Handle untuk platform mobile
            await _handleMobileFileUpload(
              result.files.single,
              fileType,
              folder,
              contentType,
              authState,
              videoState.IdVideo,
            );
          }
        } else {
          if (kIsWeb) {
            await _handleWebFileUpload(
              result.files.single,
              fileType,
              folder,
              contentType,
              authState,
              0,
            );
          } else {
            // Handle untuk platform mobile
            await _handleMobileFileUpload(
              result.files.single,
              fileType,
              folder,
              contentType,
              authState,
              0,
            );
          }
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
      int idVideo,
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
      final fileName = '$folder${_selectedMapelName ?? "MataPelajaran"}-${_judulController.text}-Kelas $_selectedKelas-${idVideo + 1}$fileExtension';

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

  // Fungsi untuk handle upload file di mobile
  Future<void> _handleMobileFileUpload(
      PlatformFile platformFile,
      String fileType,
      String folder,
      String contentType,
      Authenticated authState,
      int idVideo,
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
      final fileName = '$folder${_selectedMapelName ?? "MataPelajaran"}-${_judulController.text}-Kelas $_selectedKelas-${idVideo + 1}${_extension(file.path)}';

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
      } else if (lowerFileName.endsWith('.flv')) {
        return 'video/x-flv';
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
      } else if (lowerFilePath.endsWith('.flv')) {
        return 'video/x-flv';
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

      // Validasi extension berdasarkan file type
      if (fileType == 'gambar') {
        if (['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'].contains(extension)) {
          return extension;
        }
      } else if (fileType == 'video') {
        if (['.mp4', '.mov', '.avi', '.webm', '.mkv', '.flv'].contains(extension)) {
          return extension;
        }
      }
    }

    // Default extension berdasarkan fileType jika tidak ada extension yang valid
    switch (fileType) {
      case 'video':
        return '.mp4';
      case 'gambar':
        return '.jpg';
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

  String extension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  // Helper functions untuk mengatur state upload
  void _setUploadingState(String fileType, bool isUploading) {
    setState(() {
      switch (fileType) {
        case 'video':
          _isUploading = isUploading;
          _uploadError = null;
          break;
        case 'gambar':
          _isUploadingGambar = isUploading;
          _uploadErrorGambar = null;
          break;
      }
    });
  }

  void _setUploadErrorState(String fileType, String error) {
    setState(() {
      switch (fileType) {
        case 'video':
          _isUploading = false;
          _uploadError = error;
          break;
        case 'gambar':
          _isUploadingGambar = false;
          _uploadErrorGambar = error;
          break;
      }
    });
  }

  void _setUploadSuccessState(String fileType, String link) {
    setState(() {
      switch (fileType) {
        case 'video':
          _isUploading = false;
          _linkController.text = link;
          _uploadSuccess = 'Upload berhasil!';
          break;
        case 'gambar':
          _isUploadingGambar = false;
          _thumbnailController.text = link;
          _uploadSuccessGambar = 'Upload berhasil!';
          break;
      }
    });
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      // Validasi mata pelajaran sudah dipilih
      if (_selectedMapelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih mata pelajaran terlebih dahulu!')),
        );
        return;
      }

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
        'link_video': _linkController.text,
        'thumbnail': _thumbnailController.text != '' ? _thumbnailController.text : '-',
        'deskripsi': _deskripsiController.text,
        'id_mapel': _selectedMapelId!,
        'kelas': _selectedKelas,
        'views': widget.videoData?.views ?? 0,
        'likes': widget.videoData?.likes ?? 0,
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
      body: SafeArea(
        child: BlocListener<CloudflareBloc, CloudflareState>(
          listener: (context, state) {
            if (state is CloudFlareLoaded) {
              // Determine file type based on file name or other logic
              String fileType = 'video';
              if (state.fileName.contains('Thumbnail')) fileType = 'gambar';

              _setUploadSuccessState(fileType, 'https://edukasiin.animein.net/${state.fileName}');
            } else if (state is CloudFlareError) {
              // Handle error (you might need to track which file was being uploaded)
              _setUploadErrorState('file', state.message);
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

                  // Mata Pelajaran Dropdown
                  BlocBuilder<MataPelajaranBloc, MataPelajaranState>(
                    builder: (context, state) {
                      if (state is MataPelajaranLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is MataPelajaranLoaded) {
                        return DropdownButtonFormField<int>(
                          value: _selectedMapelId,
                          decoration: const InputDecoration(
                            labelText: 'Mata Pelajaran',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Pilih'),
                            ),
                            ...state.mataPelajaranList.map((mapel) {
                              return DropdownMenuItem<int>(
                                value: mapel.id,
                                child: Text(mapel.mapel),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMapelId = value;
                              // Store the mapel name for file naming
                              if (value != null) {
                                final selectedMapel = state.mataPelajaranList.firstWhere(
                                      (mapel) => mapel.id == value,
                                  orElse: () => state.mataPelajaranList.first,
                                );
                                _selectedMapelName = selectedMapel.mapel;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Pilih mata pelajaran terlebih dahulu';
                            }
                            return null;
                          },
                        );
                      } else if (state is MataPelajaranError) {
                        return Text('Error: ${state.message}');
                      } else {
                        return const Text('Tidak ada data mata pelajaran');
                      }
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
                      if (_judulController.text.isEmpty || _selectedMapelId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap isi judul dan pilih mata pelajaran terlebih dahulu'),
                          ),
                        );
                        return;
                      }
                      _uploadFile('video', authState);
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
                      child: Center(
                          child: Text(
                            _uploadSuccess!,
                            style: const TextStyle(color: Colors.green),
                          )
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _thumbnailController,
                    decoration: InputDecoration(
                      labelText: 'Thumbnail (Opsional)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  if (_isUploadingGambar)
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text('Uploading...'),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: _isUploadingGambar ? null : () {
                      if (_judulController.text.isEmpty || _selectedMapelId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap isi judul dan pilih mata pelajaran terlebih dahulu'),
                          ),
                        );
                        return;
                      }
                      _uploadFile('gambar', authState);
                    },
                    child: const Text('Select Gambar'),
                  ),
                  if (_uploadErrorGambar != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _uploadErrorGambar!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_uploadSuccessGambar != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                          child: Text(
                            _uploadSuccessGambar!,
                            style: const TextStyle(color: Colors.green),
                          )
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
      )
    );
  }
}