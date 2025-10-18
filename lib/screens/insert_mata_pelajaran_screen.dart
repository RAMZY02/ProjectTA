import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/models/mata_pelajaran_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class InsertMataPelajaranScreen extends StatefulWidget {
  final MataPelajaranModel? mataPelajaranData;

  bool get isEdit => mataPelajaranData != null;

  const InsertMataPelajaranScreen({
    super.key,
    this.mataPelajaranData,
  });

  @override
  State<InsertMataPelajaranScreen> createState() => _InsertMataPelajaranScreenState();
}

class _InsertMataPelajaranScreenState extends State<InsertMataPelajaranScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mataPelajaranController;

  @override
  void initState() {
    super.initState();
    _mataPelajaranController = TextEditingController(text: widget.mataPelajaranData?.mapel ?? '');
  }

  @override
  void dispose() {
    _mataPelajaranController.dispose();
    super.dispose();
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      if (!widget.isEdit) {
        if (state is Authenticated) {
          context.read<MataPelajaranBloc>().add(
              CreateMataPelajaran(
                token: state.token,
                mapel: _mataPelajaranController.text,
              )
          );
        }
      } else {
        if (state is Authenticated) {
          context.read<MataPelajaranBloc>().add(
              UpdateMataPelajaran(
                token: state.token,
                id: widget.mataPelajaranData!.id,
                mapel: _mataPelajaranController.text,
              )
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Mata pelajaran berhasil diperbarui' : 'Mata pelajaran berhasil ditambahkan'),
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
        title: Text(widget.isEdit ? 'Edit Mata Pelajaran' : 'Tambah Mata Pelajaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Mata Pelajaran
              TextFormField(
                controller: _mataPelajaranController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Pelajaran',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama mata pelajaran tidak boleh kosong';
                  }
                  if (value.length < 2) {
                    return 'Nama mata pelajaran minimal 2 karakter';
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
                  widget.isEdit ? 'Update Mata Pelajaran' : 'Simpan Mata Pelajaran',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}