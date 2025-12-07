import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/models/mata_pelajaran_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/tahun_pelajaran/tahun_pelajaran_bloc.dart';
import '../bloc/tahun_pelajaran/tahun_pelajaran_event.dart';
import '../models/tahun_pelajaran_model.dart';

class InsertTahunPelajaranScreen extends StatefulWidget {
  final TahunPelajaranModel? tahunPelajaranData;

  bool get isEdit => tahunPelajaranData != null;

  const InsertTahunPelajaranScreen({
    super.key,
    this.tahunPelajaranData,
  });

  @override
  State<InsertTahunPelajaranScreen> createState() => _InsertMataPelajaranScreenState();
}

class _InsertMataPelajaranScreenState extends State<InsertTahunPelajaranScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tahunPelajaranController;
  late String _selectedSemester;
  List<String> semester = ['1', '2'];

  @override
  void initState() {
    super.initState();
    _tahunPelajaranController = TextEditingController(text: widget.tahunPelajaranData?.tahun ?? '');
    _selectedSemester = widget.tahunPelajaranData?.semester ?? '';
  }

  @override
  void dispose() {
    _tahunPelajaranController.dispose();
    super.dispose();
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      if (!widget.isEdit) {
        if (state is Authenticated) {
          context.read<TahunPelajaranBloc>().add(
              CreateTahunPelajaran(
                token: state.token,
                tahun: _tahunPelajaranController.text,
                semester: _selectedSemester
              )
          );
        }
      } else {
        if (state is Authenticated) {
          context.read<TahunPelajaranBloc>().add(
              UpdateTahunPelajaran(
                token: state.token,
                id: widget.tahunPelajaranData!.id,
                tahun: _tahunPelajaranController.text,
                semester: _selectedSemester,
              )
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Tahun pelajaran berhasil diperbarui' : 'Tahun pelajaran berhasil ditambahkan'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Tahun Pelajaran' : 'Tambah Tahun Pelajaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tahun Pelajaran
              TextFormField(
                controller: _tahunPelajaranController,
                decoration: const InputDecoration(
                  labelText: 'Tahun Pelajaran',
                  border: OutlineInputBorder(),
                  hintText: '2025/2026'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tahun pelajaran tidak boleh kosong';
                  }
                  if (value.length < 9) {
                    return 'Tahun pelajaran minimal 9 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSemester == '' ?  null : _selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                menuMaxHeight: 200, // Alternatif lain (beberapa versi Flutter)
                isExpanded: true, // Agar dropdown mengisi lebar parent
                style: TextStyle(fontSize: 16, color:  Colors.black), // Style untuk teks yang dipilih
                iconSize: 24, // Ukuran icon dropdown
                items: semester.map((String value) {
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
                    _selectedSemester = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap pilih semester';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  _submitForm(authState);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.isEdit ? 'Update Tahun Pelajaran' : 'Simpan Tahun Pelajaran',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}