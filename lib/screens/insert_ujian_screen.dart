
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_bloc.dart';
import 'package:project_ta/bloc/ujian/ujian_event.dart';
import 'package:project_ta/models/ujian_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class InsertUjianScreen extends StatefulWidget {
  final UjianModel? ujianData;
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
  late TextEditingController _mapelController;
  late TextEditingController _tipeSoalController;
  late TextEditingController _tipeUjianController;
  late TextEditingController _waktuController;
  late TextEditingController _tanggalController;
  late TextEditingController _mulaiController;
  late TextEditingController _selesaiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _guruController;

  // Move these variables to class level so they persist across builds
  TimeOfDay? _waktu;
  DateTime? _selectedTanggal;
  TimeOfDay? _selectedMulaiTime;
  TimeOfDay? _selectedSelesaiTime;
  int? jumlahSoal;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.ujianData?.nama ?? '',
    );
    _mapelController = TextEditingController(
      text: widget.ujianData?.mapel ?? '',
    );
    _tipeSoalController = TextEditingController(
      text: widget.ujianData?.tipe_soal ?? '',
    );
    _tipeUjianController = TextEditingController(
      text: widget.ujianData?.tipe_ujian ?? '',
    );
    _waktuController = TextEditingController(
      text: widget.ujianData != null ? convertToMinutes(widget.ujianData!.durasi.toString()) : '',
    );
    _tanggalController = TextEditingController(
      text: widget.ujianData?.tanggal.toString().substring(0, 10) ?? '',
    );
    _mulaiController = TextEditingController(
      text: widget.ujianData != null ? formatTimeOfDay(widget.ujianData!.mulai) : '',
    );
    _selesaiController = TextEditingController(
      text: widget.ujianData != null ? formatTimeOfDay(widget.ujianData!.selesai) : '',
    );
    _deskripsiController = TextEditingController(
      text: widget.ujianData?.deskripsi.toString() ?? '',
    );
    _guruController = TextEditingController(
      text: widget.ujianData?.guru ?? '',
    );

    if(widget.isEdit){
      String minutes = convertToMinutes(widget.ujianData!.durasi.toString());
      _waktu = _convertMinutesToTimeOfDay(int.parse(minutes));
      _selectedTanggal = widget.ujianData!.tanggal;
      _selectedMulaiTime = widget.ujianData!.mulai;
      _selectedSelesaiTime = widget.ujianData!.selesai;
      jumlahSoal = widget.ujianData!.jumlahSoal;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _mapelController.dispose();
    _tipeSoalController.dispose();
    _tipeUjianController.dispose();
    _waktuController.dispose();
    _tanggalController.dispose();
    _mulaiController.dispose();
    _selesaiController.dispose();
    _deskripsiController.dispose();
    _guruController.dispose();
    super.dispose();
  }

  TimeOfDay _convertMinutesToTimeOfDay(int minutes) {
    // Hitung jam dan menit
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    print("ini jam");
    print(hours);
    print("ini menit");
    print(remainingMinutes);

    // Pastikan jam tidak melebihi 23 (karena TimeOfDay hanya menerima 0-23 jam)
    final adjustedHours = hours % 24;

    return TimeOfDay(hour: adjustedHours, minute: remainingMinutes);
  }

  String convertToMinutes(String timeString) {
    List<String> parts = timeString.split(':');

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    double seconds = double.parse(parts[2]);

    double totalMinutes = hours * 60 + minutes + seconds / 60;

    // Jika hasilnya bulat, kembalikan tanpa desimal, else 1 digit desimal
    return totalMinutes % 1 == 0
        ? totalMinutes.toInt().toString()
        : totalMinutes.toStringAsFixed(1);
  }

  String formatTimeOfDay(TimeOfDay time) {
    // Format jam dan menit dengan leading zero
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute'; // Format 10.00
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

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
              TextFormField(
                controller: _mapelController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan mata pelajaran',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'mata pelajaran ujian tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipeSoalController.text.isNotEmpty ? _tipeSoalController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Tipe Soal',
                  border: OutlineInputBorder(),
                ),
                items: ['Pilihan Ganda', 'Isian', 'Upload', 'Campuran']
                    .map((tipe) => DropdownMenuItem(
                  value: tipe,
                  child: Text(tipe),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipeSoalController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih tipe soal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipeUjianController.text.isNotEmpty ? _tipeUjianController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Tipe Ujian',
                  border: OutlineInputBorder(),
                ),
                items: ['UTS', 'UAS', 'Ujian Harian']
                    .map((tipe) => DropdownMenuItem(
                  value: tipe,
                  child: Text(tipe),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipeUjianController.text = value!;
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
                onChanged: (value) {
                  if (value.isNotEmpty && int.tryParse(value) != null) {
                    setState(() {
                      _waktu = _convertMinutesToTimeOfDay(int.parse(value));
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Ujian',
                  border: OutlineInputBorder(),
                  hintText: 'DD-MM-YYYY',
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _tanggalController.text =
                      "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                      _selectedTanggal = date;
                    });
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
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _mulaiController.text =
                      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                      _selectedMulaiTime = time;
                    });
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
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selesaiController.text =
                      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                      _selectedSelesaiTime = time;
                    });
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
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  hintText: 'Deskripsi',
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
              DropdownButtonFormField<String>(
                value: _guruController.text.isNotEmpty ? _guruController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Nama Guru Pengajar',
                  border: OutlineInputBorder(),
                ),
                items: ['Guruku', 'Guruku2', 'Guruku3', 'Guruku4']
                    .map((tipe) => DropdownMenuItem(
                  value: tipe,
                  child: Text(tipe),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _guruController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih nama guru';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Additional validation for required fields
                    if (_waktu == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Waktu pengerjaan belum diisi dengan benar')),
                      );
                      return;
                    }
                    if (_selectedTanggal == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanggal ujian belum dipilih')),
                      );
                      return;
                    }
                    if (_selectedMulaiTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jam mulai belum dipilih')),
                      );
                      return;
                    }
                    if (_selectedSelesaiTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jam selesai belum dipilih')),
                      );
                      return;
                    }

                    if (!widget.isEdit) {
                      if (authState is Authenticated) {
                        print("masuk sini kah");
                        context.read<UjianBloc>().add(AddUjian(
                          token: authState.token,
                          nama: _namaController.text,
                          mapel: _mapelController.text,
                          tipe_soal: _tipeSoalController.text,
                          tipe_ujian: _tipeUjianController.text,
                          durasi: _waktu!,
                          tanggal: _selectedTanggal!,
                          mulai: _selectedMulaiTime!,
                          selesai: _selectedSelesaiTime!,
                          deskripsi: _deskripsiController.text,
                          id_guru: 5,
                        ));
                      }
                    } else {
                      if (authState is Authenticated) {
                        context.read<UjianBloc>().add(UpdateUjian(
                          token: authState.token,
                          id_ujian: widget.ujianData!.id,
                          nama: _namaController.text,
                          mapel: _mapelController.text,
                          tipe_soal: _tipeSoalController.text,
                          tipe_ujian: _tipeUjianController.text,
                          durasi: _waktu!,
                          tanggal: _selectedTanggal!,
                          mulai: _selectedMulaiTime!,
                          selesai: _selectedSelesaiTime!,
                          deskripsi: _deskripsiController.text,
                          id_guru: 5,
                        ));
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.isEdit
                              ? 'Ujian berhasil diperbarui'
                              : 'Ujian berhasil ditambahkan',
                        ),
                      ),
                    );
                    Navigator.pop(context);
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