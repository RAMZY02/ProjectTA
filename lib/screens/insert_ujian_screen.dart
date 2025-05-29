import 'package:flutter/material.dart';

class InsertUjianScreen extends StatefulWidget {
  final Map<String, dynamic>? ujianData;
  final bool isEdit;

  const InsertUjianScreen({
    super.key,
    this.ujianData,
    this.isEdit = false,
  });

  @override
  State<InsertUjianScreen> createState() => _InsertUjianScreenState();
}

class _InsertUjianScreenState extends State<InsertUjianScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _tipeController;
  late TextEditingController _waktuController;
  late TextEditingController _tanggalController;
  late TextEditingController _mulaiController;
  late TextEditingController _selesaiController;
  late TextEditingController _jumlahSoalController;
  late TextEditingController _guruController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.ujianData?['nama'] ?? '',
    );
    _tipeController = TextEditingController(
      text: widget.ujianData?['tipe'] ?? '',
    );
    _waktuController = TextEditingController(
      text: widget.ujianData?['waktu'] ?? '',
    );
    _tanggalController = TextEditingController(
      text: widget.ujianData?['tanggal'] ?? '',
    );
    _mulaiController = TextEditingController(
      text: widget.ujianData?['mulai'] ?? '',
    );
    _selesaiController = TextEditingController(
      text: widget.ujianData?['selesai'] ?? '',
    );
    _jumlahSoalController = TextEditingController(
      text: widget.ujianData?['jumlah_soal']?.toString() ?? '',
    );
    _guruController = TextEditingController(
      text: widget.ujianData?['guru'] ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tipeController.dispose();
    _waktuController.dispose();
    _tanggalController.dispose();
    _mulaiController.dispose();
    _selesaiController.dispose();
    _jumlahSoalController.dispose();
    _guruController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Ujian' : 'Tambah Ujian'),
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
                  labelText: 'Nama Ujian',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nama ujian',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama ujian tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipeController.text.isNotEmpty ? _tipeController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Tipe Ujian',
                  border: OutlineInputBorder(),
                ),
                items: ['UTS', 'UAS', 'Ujian Harian', 'Try Out']
                    .map((tipe) => DropdownMenuItem(
                  value: tipe,
                  child: Text(tipe),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipeController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih tipe ujian';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _waktuController,
                decoration: const InputDecoration(
                  labelText: 'Waktu Pengerjaan (menit)',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 120',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu pengerjaan tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Ujian',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _tanggalController.text =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mulaiController,
                decoration: const InputDecoration(
                  labelText: 'Jam Mulai',
                  border: OutlineInputBorder(),
                  hintText: 'HH:MM',
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    _mulaiController.text =
                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jam mulai tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _selesaiController,
                decoration: const InputDecoration(
                  labelText: 'Jam Selesai',
                  border: OutlineInputBorder(),
                  hintText: 'HH:MM',
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    _selesaiController.text =
                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jam selesai tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahSoalController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Soal',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 50',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah soal tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guruController,
                decoration: const InputDecoration(
                  labelText: 'Nama Guru Pengampu',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan nama guru',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama guru tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save logic here
                    final ujianData = {
                      'nama': _namaController.text,
                      'tipe': _tipeController.text,
                      'waktu': int.parse(_waktuController.text),
                      'tanggal': _tanggalController.text,
                      'mulai': _mulaiController.text,
                      'selesai': _selesaiController.text,
                      'jumlah_soal': int.parse(_jumlahSoalController.text),
                      'guru': _guruController.text,
                    };

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.isEdit
                              ? 'Ujian berhasil diperbarui'
                              : 'Ujian berhasil ditambahkan',
                        ),
                      ),
                    );
                    Navigator.pop(context, ujianData);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}