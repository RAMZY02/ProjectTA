import 'package:flutter/material.dart';

class InsertUserScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
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
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData?['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData?['email'] ?? '',
    );
    _roleController = TextEditingController(
      text: widget.userData?['role'] ?? 'User',
    );
  }

  @override
  Widget build(BuildContext context) {
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
              DropdownButtonFormField<String>(
                value: _roleController.text,
                items: ['Admin', 'User']
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
                    .toList(),
                onChanged: (value) {
                  _roleController.text = value!;
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
                    // Save logic here
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