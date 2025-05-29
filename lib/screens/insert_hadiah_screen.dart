import 'package:flutter/material.dart';

class InsertHadiahScreen extends StatefulWidget {
  final Map<String, dynamic>? hadiahData;

  // Ini akan otomatis true jika hadiahData tidak null
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

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data yang ada jika dalam mode edit
    _namaController = TextEditingController(
      text: widget.hadiahData?['nama'] ?? '',
    );
    _poinController = TextEditingController(
      text: widget.hadiahData?['poin']?.toString() ?? '',
    );
    _stokController = TextEditingController(
      text: widget.hadiahData?['stok']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _poinController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Kembali ke halaman sebelumnya dengan data hadiah
      final newHadiah = {
        'id': widget.isEdit ? widget.hadiahData!['id'] : null, // ID akan di-set di MasterHadiahScreen
        'nama': _namaController.text,
        'poin': int.parse(_poinController.text),
        'stok': int.parse(_stokController.text),
      };

      Navigator.pop(context, newHadiah);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Hadiah' : 'Tambah Hadiah'),
      ),
      body: Padding(
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
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