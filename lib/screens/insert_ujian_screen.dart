
import 'dart:math';

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
  late TextEditingController _tanggalController;
  late TextEditingController _mulaiController;
  late TextEditingController _selesaiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _kelasController;
  late TextEditingController _tingkatanController;

  final List<String> _kelasOptions = [
    '7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J',
    '8A', '8B', '8C', '8D', '8E', '8F', '8G', '8H', '8I', '8J',
    '9A', '9B', '9C', '9D', '9E', '9F', '9G', '9H', '9I', '9J'
  ];

  final List<String> _tingkatanOptions = [
    '7', '8', '9'
  ];

  // Move these variables to class level so they persist across builds
  DateTime? _selectedTanggal;
  TimeOfDay? _selectedMulaiTime;
  TimeOfDay? _selectedSelesaiTime;
  int? jumlahSoal;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _namaController = TextEditingController(
      text: widget.ujianData?.nama ?? '',
    );
    if(authState is Authenticated){
      _mapelController = TextEditingController(
        text: authState.mapel != '-' ? authState.mapel : '',
      );
    }
    _tipeSoalController = TextEditingController(
      text: widget.ujianData?.tipe_soal ?? '',
    );
    _tipeUjianController = TextEditingController(
      text: widget.ujianData?.tipe_ujian ?? '',
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
    _kelasController = TextEditingController(
      text: widget.ujianData?.kelas ?? '',
    );
    _tingkatanController = TextEditingController(
      text: widget.ujianData?.tingkatan ?? '',
    );

    if(widget.isEdit){
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
    _tanggalController.dispose();
    _mulaiController.dispose();
    _selesaiController.dispose();
    _deskripsiController.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                  decoration: InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: const OutlineInputBorder(),
                    hintText: 'Masukkan mata pelajaran',
                    filled: true, // Tambahkan background agar terlihat berbeda
                    fillColor: Colors.grey[100], // Warna background untuk menandakan read-only
                  ),
                  readOnly: true, // Ini yang membuatnya tidak bisa diedit
                  enabled: true, // Biarkan enabled agar tetap terlihat normal
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
                  items: ['Pilihan Ganda', 'Isian', 'Upload Foto', 'Campuran']
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
                Visibility(
                  visible: _tipeUjianController.text == 'UTS' || _tipeUjianController.text == 'UAS',
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _tingkatanController.text.isNotEmpty ? _tingkatanController.text : null,
                        decoration: InputDecoration(
                          labelText: 'Kelas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        menuMaxHeight: 200, // Alternatif lain (beberapa versi Flutter)
                        isExpanded: true, // Agar dropdown mengisi lebar parent
                        style: TextStyle(fontSize: 16, color:  Colors.black), // Style untuk teks yang dipilih
                        iconSize: 24, // Ukuran icon dropdown
                        items: _tingkatanOptions.map((String value) {
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
                            _tingkatanController.text = newValue ?? '';
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
                Visibility(
                  visible: _tipeUjianController.text == 'Ujian Harian',
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _kelasController.text.isNotEmpty ? _kelasController.text : null,
                        decoration: InputDecoration(
                          labelText: 'Kelas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
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
                    hintText: 'HH:MM (contoh : 20:59)',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
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
                    hintText: 'HH:MM (contoh : 20:59)',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Additional validation for required fields

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
                          final randomCode = generateRandomAlphanumeric(6);
                          context.read<UjianBloc>().add(AddUjian(
                            token: authState.token,
                            nama: _namaController.text,
                            id_mapel: authState.id_mapel,
                            tingkatan: _tingkatanController.text,
                            kelas: _kelasController.text,
                            tipe_soal: _tipeSoalController.text,
                            tipe_ujian: _tipeUjianController.text,
                            tanggal: _selectedTanggal!,
                            mulai: _selectedMulaiTime!,
                            selesai: _selectedSelesaiTime!,
                            deskripsi: _deskripsiController.text,
                            kode: randomCode,
                            id_guru: authState.id,
                          ));
                        }
                      } else {
                        if (authState is Authenticated) {
                          context.read<UjianBloc>().add(UpdateUjian(
                            token: authState.token,
                            id_ujian: widget.ujianData!.id,
                            nama: _namaController.text,
                            id_mapel: authState.id_mapel,
                            tingkatan: _tingkatanController.text,
                            kelas: _kelasController.text,
                            tipe_soal: _tipeSoalController.text,
                            tipe_ujian: _tipeUjianController.text,
                            tanggal: _selectedTanggal!,
                            mulai: _selectedMulaiTime!,
                            selesai: _selectedSelesaiTime!,
                            deskripsi: _deskripsiController.text,
                            id_guru: authState.id,
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
      )
    );
  }

  String generateRandomAlphanumeric(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}