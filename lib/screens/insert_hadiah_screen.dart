import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_event.dart';
import 'package:project_ta/models/hadiah_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

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
  File? _gambarFile;
  String? _gambarPath;
  late String _selectedKategori;

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

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _gambarFile = File(file.path);
        _gambarPath = file.path;
      });
    }
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      if (_gambarFile == null && _gambarPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih gambar hadiah')),
        );
        return;
      }

      if (!widget.isEdit) {
        if (state is Authenticated) {
          print("masuk sini kah");
          context.read<HadiahBloc>().add(AddHadiah(token: state.token, nama: _namaController.text, poin: int.parse(_poinController.text), stok: int.parse(_stokController.text), kategori: _selectedKategori, linkGambar: _gambarPath.toString()));
        }
      } else {
        if (state is Authenticated) {
          context.read<HadiahBloc>().add(UpdateHadiah(token: state.token, hadiahId: widget.hadiahData!.id, nama: _namaController.text, poin: int.parse(_poinController.text), stok: int.parse(_stokController.text), kategori: _selectedKategori, linkGambar: _gambarPath.toString()));
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
        title: Text(widget.isEdit ? 'Edit Hadiah' : 'Tambah Hadiah'),
      ),
      body: SingleChildScrollView(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gambar Hadiah',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _gambarFile != null
                          ? Image.file(_gambarFile!, fit: BoxFit.cover)
                          : _gambarPath != null
                          ? Image.network(_gambarPath!, fit: BoxFit.cover)
                          : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 50, color: Colors.grey),
                            Text('Tap untuk memilih gambar'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (){
                  _submitForm(authState);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.isEdit ? 'Update Hadiah' : 'Simpan Hadiah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}