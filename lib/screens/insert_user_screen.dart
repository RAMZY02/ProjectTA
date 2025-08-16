import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/models/user_model.dart';

import '../bloc/auth/auth_bloc.dart';
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
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _roleController;
  late TextEditingController _kelasController;
  late TextEditingController _mapelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData?.nama ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData?.email ?? '',
    );
    _roleController = TextEditingController(
      text: widget.userData?.role ?? 'siswa',
    );
    _passwordController = TextEditingController(
      text: '',
    );
    _kelasController = TextEditingController(
      text: widget.userData?.kelas ?? '',
    );
    _mapelController = TextEditingController(
      text: widget.userData?.mapel ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit User' : 'Tambah User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: 16),
              if(!widget.isEdit)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              // TextField Kelas akan muncul/hilang otomatis
              if(_roleController.text == "siswa")
                const SizedBox(height: 16),
              Visibility(
                visible: _roleController.text == 'siswa',
                child: TextFormField(
                  controller: _kelasController,
                  decoration: InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _kelasController.text = value;
                  },
                ),
              ),
              if(_roleController.text == "guru")
                const SizedBox(height: 16),
              Visibility(
                visible: _roleController.text == 'guru',
                child: TextFormField(
                  controller: _mapelController,
                  decoration: InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _mapelController.text = value;
                  },
                ),
              ),
              if(!widget.isEdit)
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
                  _roleController.text = value!;
                  if(value != 'siswa'){
                    _kelasController.text = '-';
                  }
                  setState(() {});
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
                    if(!widget.isEdit){
                      if(authState is Authenticated){
                        context.read<UsersBloc>().add(AddUsers(token: authState.token, nama: _nameController.text, email: _emailController.text, password: _passwordController.text, role: _roleController.text, kelas: _kelasController.text));
                      }
                    }
                    else{
                      if(authState is Authenticated){
                        context.read<UsersBloc>().add(UpdateUsers(token: authState.token, id_user: widget.userData!.id, nama: _nameController.text, email: _emailController.text, role: _roleController.text, kelas: _kelasController.text));
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
    );
  }
}