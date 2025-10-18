import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_state.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/models/user_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/cloudflare/cloudflare_bloc.dart';
import '../bloc/cloudflare/cloudflare_event.dart';
import '../bloc/cloudflare/cloudflare_state.dart';
import '../bloc/users/users_bloc.dart';

class InsertUserScreen extends StatefulWidget {
  final UserModel? userData;
  final bool isEdit;

  const InsertUserScreen({
    super.key,
    this.userData,
    this.isEdit = false,
  });

  @override
  State<InsertUserScreen> createState() => _InsertUserScreenState();
}

class _InsertUserScreenState extends State<InsertUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nisController;
  late TextEditingController _nisnController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _roleController;
  late TextEditingController _kelasController;
  late TextEditingController _agamaController;
  late TextEditingController _waliKelasController;
  late TextEditingController _nomorOrtuController;

  // Upload state variables
  bool _isUploading = false;
  String? _uploadError;
  String? _uploadSuccess;
  String? _profpicUrl;
  int? _selectedMapelId;

  final List<String> _kelasOptions = [
    '7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J',
    '8A', '8B', '8C', '8D', '8E', '8F', '8G', '8H', '8I', '8J',
    '9A', '9B', '9C', '9D', '9E', '9F', '9G', '9H', '9I', '9J'
  ];

  final List<String> _agamaOptions = [
    'Islam', 'Hindu', 'Kristen', 'Katolik'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData?.nama ?? '',
    );
    _nisController = TextEditingController(
      text: widget.userData?.nis ?? '',
    );
    _nisnController = TextEditingController(
      text: widget.userData?.nisn ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData?.email ?? '',
    );
    _roleController = TextEditingController(
      text: widget.userData?.role ?? 'siswa',
    );
    _passwordController = TextEditingController(text: '');
    if(widget.isEdit){
      _kelasController = TextEditingController(
        text: widget.userData?.kelas != '-' ? widget.userData!.kelas : '',
      );
      _agamaController = TextEditingController(
        text: widget.userData?.agama != '-' ? widget.userData!.agama : '',
      );
      _waliKelasController = TextEditingController(
        text: widget.userData?.wali_kelas != '-' ? widget.userData!.wali_kelas : '',
      );
    }
    else{
      _kelasController = TextEditingController(
        text: '',
      );
      _agamaController = TextEditingController(
        text: '',
      );
      _waliKelasController = TextEditingController(
        text: '',
      );
    }
    _nomorOrtuController = TextEditingController(
      text: widget.userData?.nomor_ortu ?? '',
    );

    _selectedMapelId = widget.userData?.id_mapel != 0 ? widget.userData?.id_mapel : null;

    // Set initial profpic URL if editing
    _profpicUrl = widget.userData?.profpic;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<MataPelajaranBloc>().add(FetchAllMataPelajaran(token: authState.token));
    }
  }

  Future<void> _selectImage(AuthState state) async {
    if (state is! Authenticated) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
          _uploadError = null;
        });

        // Handle untuk platform web
        if (kIsWeb) {
          await _handleWebImageUpload(result.files.single, state);
        } else {
          // Handle untuk platform mobile
          await _handleMobileImageUpload(result.files.single, state);
        }
      }
    } catch (e) {
      _handleUploadError('Gagal memilih gambar: ${e.toString()}');
    }
  }

// Fungsi untuk handle upload image di web
  Future<void> _handleWebImageUpload(PlatformFile platformFile, Authenticated state) async {
    try {
      // Validasi file untuk web
      if (platformFile.bytes == null) {
        _handleUploadError('Tidak dapat membaca file gambar');
        return;
      }

      // Tentukan content type berdasarkan nama file
      final contentType = _getImageContentTypeForWeb(platformFile.name);

      // Dapatkan extension file yang tepat
      final fileExtension = _getImageExtensionForWeb(platformFile.name);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ProfilePictures/${_nameController.text}-$timestamp$fileExtension';

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
      _handleUploadError('Gagal upload gambar: ${e.toString()}');
    }
  }

  // Fungsi untuk handle upload image di mobile
  Future<void> _handleMobileImageUpload(PlatformFile platformFile, Authenticated state) async {
    try {
      // Validasi path file untuk mobile
      if (platformFile.path == null) {
        _handleUploadError('Tidak dapat mengakses file');
        return;
      }

      File file = File(platformFile.path!);

      // Tentukan content type berdasarkan extension file
      final contentType = _getImageContentTypeForMobile(file.path);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ProfilePictures/${_nameController.text}-$timestamp${_getFileExtension(file.path)}';

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
      _handleUploadError('Gagal upload gambar: ${e.toString()}');
    }
  }

  // Helper function untuk menentukan content type image di web
  String _getImageContentTypeForWeb(String fileName) {
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
    }

    // Default ke JPEG
    return 'image/jpeg';
  }

  // Helper function untuk menentukan content type image di mobile
  String _getImageContentTypeForMobile(String filePath) {
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
    }

    // Default ke JPEG
    return 'image/jpeg';
  }

  // Helper function untuk mendapatkan extension image di web
  String _getImageExtensionForWeb(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex).toLowerCase();
    }

    // Default extension untuk gambar
    return '.jpg';
  }

  // Helper function untuk mendapatkan extension file (untuk mobile)
  String _getFileExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      return filePath.substring(dotIndex).toLowerCase();
    }
    return '.jpg';
  }


  // Helper function untuk handle error
  void _handleUploadError(String errorMessage) {
    setState(() {
      _uploadError = errorMessage;
      _isUploading = false;
    });

    // Tampilkan snackbar error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return BlocListener<CloudflareBloc, CloudflareState>(
      listener: (context, state) {
        if (state is CloudFlareLoaded) {
          setState(() {
            _isUploading = false;
            _uploadSuccess = 'Gambar berhasil diupload!';
            _profpicUrl = 'https://edukasiin.animein.net/${state.fileName}';
          });

          // Clear success message after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              _uploadSuccess = null;
            });
          });
        } else if (state is CloudFlareError) {
          setState(() {
            _isUploading = false;
            _uploadError = 'Upload gagal: ${state.message}';
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit User' : 'Tambah User'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Profile Picture Upload Section (only for edit mode)
                if (widget.isEdit) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Foto Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Current profile picture preview
                  if (_profpicUrl != null && _profpicUrl != '-')
                    Column(
                      children: [
                        Image.network(
                          _profpicUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Foto saat ini',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: _profpicUrl ?? '-'),
                    decoration: InputDecoration(
                      labelText: 'Link Foto Profil',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    readOnly: true,
                  ),

                  const SizedBox(height: 16),
                  if (_isUploading)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Uploading...'),
                      ],
                    ),

                  ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () {
                      _selectImage(authState);
                    },
                    child: const Text('Pilih Gambar Profil'),
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
                      child: Text(
                        _uploadSuccess!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],

                // Rest of the form fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                if(_roleController.text == 'siswa')...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nisController,
                    decoration: const InputDecoration(
                      labelText: 'NIS',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NIS tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nisnController,
                    decoration: const InputDecoration(
                      labelText: 'NISN',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NISN tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),

                if(!widget.isEdit)...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                ],

                if(_roleController.text == 'siswa')...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nomorOrtuController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Orang Tua',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor orang tua tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],

                // Kelas field for siswa
                Visibility(
                  visible: _roleController.text == 'siswa',
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _agamaController.text.isNotEmpty ? _agamaController.text : null,
                        decoration: InputDecoration(
                          labelText: 'Agama',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        menuMaxHeight: 200, // Alternatif lain (beberapa versi Flutter)
                        isExpanded: true, // Agar dropdown mengisi lebar parent
                        style: TextStyle(fontSize: 16, color:  Colors.black), // Style untuk teks yang dipilih
                        iconSize: 24, // Ukuran icon dropdown
                        items: _agamaOptions.map((String value) {
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
                            _agamaController.text = newValue ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih Agama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                    ],
                  ),
                ),

                // Mapel field for guru
                Visibility(
                  visible: _roleController.text == 'guru',
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
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
                                  child: Text('Pilih Mata Pelajaran'),
                                ),
                                ...state.mataPelajaranList.map((mapel) {
                                  return DropdownMenuItem<int>(
                                    value: mapel.id,
                                    child: Text(mapel.mapel),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedMapelId = value;
                                });
                              },
                              validator: (value) {
                                if (_roleController.text == 'guru' && value == null) {
                                  return 'Mata pelajaran harus dipilih untuk guru';
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
                    ],
                  ),
                ),

                // Wali Kelas field for guru
                Visibility(
                  visible: _roleController.text == 'guru',
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _waliKelasController.text.isNotEmpty ? _waliKelasController.text : null,
                        decoration: InputDecoration(
                          labelText: 'Wali Kelas',
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
                            _waliKelasController.text = newValue ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih kelas';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _roleController.text,
                  items: ['admin', 'siswa', 'guru']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _roleController.text = value!;
                      // Reset optional fields when role changes
                      if (value != 'siswa') {
                        _kelasController.text = '';
                        _nomorOrtuController.text = '';
                      }
                      if (value != 'guru') {
                        _waliKelasController.text = '';
                        _selectedMapelId = null;
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (authState is Authenticated) {
                        if (!widget.isEdit) {
                          context.read<UsersBloc>().add(AddUsers(
                            token: authState.token,
                            nama: _nameController.text,
                            nis: _nisController.text,
                            nisn: _nisnController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            role: _roleController.text,
                            kelas: _kelasController.text.isNotEmpty ? _kelasController.text : '-',
                            id_mapel:  _selectedMapelId ?? 0,
                            wali_kelas: _waliKelasController.text.isNotEmpty ? _waliKelasController.text : '-',
                            nomorOrtu: _nomorOrtuController.text,
                            profpic: _profpicUrl ?? widget.userData?.profpic ?? '-',
                            agama: _agamaController.text.isNotEmpty ? _agamaController.text : '-'
                          ));
                        } else {
                          context.read<UsersBloc>().add(UpdateUsers(
                            token: authState.token,
                            id_user: widget.userData!.id,
                            nama: _nameController.text,
                            nis: _nisController.text,
                            nisn: _nisnController.text,
                            email: _emailController.text,
                            role: _roleController.text,
                            kelas: _kelasController.text.isNotEmpty ? _kelasController.text : '-',
                            id_mapel:  _selectedMapelId ?? 0,
                            wali_kelas: _waliKelasController.text.isNotEmpty ? _waliKelasController.text : '-',
                            nomorOrtu: _nomorOrtuController.text,
                            profpic: _profpicUrl ?? widget.userData?.profpic ?? '-',
                            agama: _agamaController.text.isNotEmpty ? _agamaController.text : '-'
                          ));
                        }
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isEdit
                                ? 'User updated successfully'
                                : 'User added successfully',
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.isEdit ? 'Update' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}