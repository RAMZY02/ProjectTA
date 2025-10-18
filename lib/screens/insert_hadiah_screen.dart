import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/models/hadiah_model.dart';
import 'dart:io';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';
import '../bloc/hadiah/hadiah_bloc.dart';
import '../bloc/hadiah/hadiah_event.dart';

class InsertHadiahScreen extends StatefulWidget {
  final HadiahModel? hadiahData;

  bool get isEdit => hadiahData != null;

  const InsertHadiahScreen({
    super.key,
    this.hadiahData,
  });

  @override
  State<InsertHadiahScreen> createState() => _InsertHadiahScreenState();
}

class _InsertHadiahScreenState extends State<InsertHadiahScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _poinController;
  late TextEditingController _stokController;
  String? _gambarPath;
  late String _selectedKategori;
  bool _isUploadingGambar = false;
  String? _uploadErrorGambar;
  String? _uploadSuccessGambar;

  final List<String> _kategoriOptions = [
    'Alat Tulis',
    'Jajanan',
    'Minuman'
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.hadiahData?.nama ?? '',
    );
    _poinController = TextEditingController(
      text: widget.hadiahData?.poin.toString() ?? '',
    );
    _stokController = TextEditingController(
      text: widget.hadiahData?.stok.toString() ?? '',
    );
    _selectedKategori = widget.hadiahData?.kategori ?? 'Alat Tulis';

    // Initialize with existing image path if in edit mode
    if (widget.isEdit && widget.hadiahData!.link_gambar.isNotEmpty) {
      _gambarPath = widget.hadiahData!.link_gambar;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _poinController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _selectGambar(AuthState state) async {
    if (state is! Authenticated) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isUploadingGambar = true;
          _uploadErrorGambar = null;
          _uploadSuccessGambar = null;
        });

        // Handle untuk platform web
        if (kIsWeb) {
          await _handleWebGambarUpload(result.files.first, state);
        } else {
          // Handle untuk platform mobile
          await _handleMobileGambarUpload(result.files.first, state);
        }
      }
    } catch (e) {
      _handleGambarUploadError('Gagal memilih gambar: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload gambar di web
  Future<void> _handleWebGambarUpload(PlatformFile platformFile, Authenticated state) async {
    try {
      // Validasi file untuk web
      if (platformFile.bytes == null) {
        _handleGambarUploadError('Tidak dapat membaca file gambar');
        return;
      }

      // Tentukan content type berdasarkan nama file
      final contentType = _getGambarContentTypeForWeb(platformFile.name);

      // Dapatkan extension file yang tepat
      final fileExtension = _getGambarExtensionForWeb(platformFile.name);

      // Generate unique file name
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'Hadiah/${_namaController.text}_Kategori $_selectedKategori$fileExtension';

      // Upload to Cloudflare untuk web
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileWeb: platformFile.bytes, // Gunakan bytes untuk web
          contentType: contentType,
          token: state.token,
        ),
      );

    } catch (e) {
      _handleGambarUploadError('Gagal upload gambar: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload gambar di mobile
  Future<void> _handleMobileGambarUpload(PlatformFile platformFile, Authenticated state) async {
    try {
      // Validasi path file untuk mobile
      if (platformFile.path == null) {
        _handleGambarUploadError('Tidak dapat mengakses file');
        return;
      }

      File file = File(platformFile.path!);

      // Tentukan content type berdasarkan extension file
      final contentType = _getGambarContentTypeForMobile(file.path);

      // Generate unique file name
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'Hadiah/${_namaController.text}_Kategori $_selectedKategori${_extension(file.path)}';

      // Upload to Cloudflare untuk mobile
      context.read<CloudflareBloc>().add(
        UploadFile(
          fileName: fileName,
          fileContent: file, // Gunakan File untuk mobile
          contentType: contentType,
          token: state.token,
        ),
      );

    } catch (e) {
      _handleGambarUploadError('Gagal upload gambar: ${e.toString()}');
    }
  }

  // Helper function untuk menentukan content type gambar di web
  String _getGambarContentTypeForWeb(String fileName) {
    final lowerFileName = fileName.toLowerCase();

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
    } else if (lowerFileName.endsWith('.svg')) {
      return 'image/svg+xml';
    } else if (lowerFileName.endsWith('.heic')) {
      return 'image/heic';
    } else if (lowerFileName.endsWith('.heif')) {
      return 'image/heif';
    }

    // Default ke JPEG
    return 'image/jpeg';
  }

  // Helper function untuk menentukan content type gambar di mobile
  String _getGambarContentTypeForMobile(String filePath) {
    final lowerFilePath = filePath.toLowerCase();

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
    } else if (lowerFilePath.endsWith('.heic')) {
      return 'image/heic';
    } else if (lowerFilePath.endsWith('.heif')) {
      return 'image/heif';
    }

    // Default ke JPEG
    return 'image/jpeg';
  }

  // Helper function untuk mendapatkan extension gambar di web
  String _getGambarExtensionForWeb(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      final extension = fileName.substring(dotIndex).toLowerCase();
      // Validasi extension yang diizinkan
      if (['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.svg'].contains(extension)) {
        return extension;
      }
    }

    // Default extension untuk gambar
    return '.jpg';
  }

  // Helper function untuk mendapatkan extension file (untuk mobile)
  String _extension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      final ext = filePath.substring(dotIndex).toLowerCase();
      // Validasi extension yang diizinkan
      if (['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp', '.heic', '.heif'].contains(ext)) {
        return ext;
      }
    }
    return '.jpg';
  }

  // Helper function untuk handle error
  void _handleGambarUploadError(String errorMessage) {
    setState(() {
      _isUploadingGambar = false;
      _uploadErrorGambar = errorMessage;
    });

    // Tampilkan snackbar error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String extension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      if (_gambarPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan upload gambar hadiah terlebih dahulu')),
        );
        return;
      }

      if (state is Authenticated) {
        if (!widget.isEdit) {
          context.read<HadiahBloc>().add(
            AddHadiah(
              token: state.token,
              nama: _namaController.text,
              poin: int.parse(_poinController.text),
              stok: int.parse(_stokController.text),
              kategori: _selectedKategori,
              linkGambar: _gambarPath!,
            ),
          );
        } else {
          context.read<HadiahBloc>().add(
            UpdateHadiah(
              token: state.token,
              hadiahId: widget.hadiahData!.id,
              nama: _namaController.text,
              poin: int.parse(_poinController.text),
              stok: int.parse(_stokController.text),
              kategori: _selectedKategori,
              linkGambar: _gambarPath!,
            ),
          );
        }

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Hadiah' : 'Tambah Hadiah'),
      ),
      body: SafeArea(
        child: BlocListener<CloudflareBloc, CloudflareState>(
          listener: (context, state) {
            if (state is CloudFlareLoading) {
              setState(() => _isUploadingGambar = true);
            }
            else if (state is CloudFlareLoaded) {
              setState(() {
                _isUploadingGambar = false;
                _gambarPath = 'https://edukasiin.animein.net/${state.fileName}';
                _uploadSuccessGambar = 'Gambar berhasil diupload';
                _uploadErrorGambar = null;
              });
            }
            else if (state is CloudFlareError) {
              setState(() {
                _isUploadingGambar = false;
                _uploadErrorGambar = state.message;
                _uploadSuccessGambar = null;
              });
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Hadiah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama hadiah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _poinController,
                    decoration: const InputDecoration(
                      labelText: 'Poin',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Poin tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Poin harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stokController,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (int.parse(value) < 0) {
                        return 'Stok tidak boleh negatif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _kategoriOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedKategori = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih kategori hadiah';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Upload Gambar Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gambar Hadiah',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Gambar Preview
                      Center(
                        child: GestureDetector(
                          onTap: () => _selectGambar(authState),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 600, // Atur maksimum width sesuai kebutuhan
                              maxHeight: 400, // Opsional: batasi height juga
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                              ),
                              child: _isUploadingGambar
                                  ? const Center(child: CircularProgressIndicator())
                                  : _gambarPath != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _gambarPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error, color: Colors.red),
                                          Text('Gagal memuat gambar'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                                  : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap untuk memilih gambar'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Status Upload
                      if (_isUploadingGambar)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                                SizedBox(height: 8),
                                Text('Mengupload gambar...'),
                              ],
                            ),
                          ),
                        ),

                      if (_uploadSuccessGambar != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Center(
                              child: Text(
                                _uploadSuccessGambar!,
                                style: const TextStyle(color: Colors.green),
                              ),
                            )
                        ),

                      if (_uploadErrorGambar != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _uploadErrorGambar!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () => _submitForm(authState),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      widget.isEdit ? 'Update Hadiah' : 'Simpan Hadiah',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
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