import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_bloc.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_event.dart';
import 'package:project_ta/bloc/kelas_mengajar/kelas_mengajar_state.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/models/kelas_mengajar_model.dart';
import 'package:project_ta/models/user_model.dart';

import '../bloc/users/users_bloc.dart';

class InsertKelasMengajarScreen extends StatefulWidget {
  final KelasMengajarModel? kelasMengajarData;

  bool get isEdit => kelasMengajarData != null;

  const InsertKelasMengajarScreen({
    super.key,
    this.kelasMengajarData
  });

  @override
  State<InsertKelasMengajarScreen> createState() => _InsertKelasMengajarScreenState();
}

class _InsertKelasMengajarScreenState extends State<InsertKelasMengajarScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<String> _selectedKelasList;
  final List<String> _availableKelas = [];
  int? _selectedGuruId;
  String? _selectedGuruName;

  @override
  void initState() {
    super.initState();

    // Generate list kelas yang tersedia: 7A-7J, 8A-8J, 9A-9J
    _generateAvailableKelas();

    // Initialize selected kelas list
    if (widget.isEdit) {
      _selectedKelasList = [widget.kelasMengajarData!.kelas];
      _selectedGuruId = widget.kelasMengajarData!.idUser;
    } else {
      _selectedKelasList = [''];
    }

    // Fetch data guru saat init
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<UsersBloc>().add(FetchUsersByRoleGuru(
        token: authState.token,
      ));
    }
  }

  void _generateAvailableKelas() {
    _availableKelas.clear();
    for (int tingkat = 7; tingkat <= 9; tingkat++) {
      for (String huruf in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']) {
        _availableKelas.add('$tingkat$huruf');
      }
    }
  }

  void _addKelasDropdown() {
    setState(() {
      _selectedKelasList.add('');
    });
  }

  void _removeKelasDropdown(int index) {
    setState(() {
      if (_selectedKelasList.length > 1) {
        _selectedKelasList.removeAt(index);
      }
    });
  }

  void _updateSelectedKelas(int index, String? value) {
    setState(() {
      if (value != null && value.isNotEmpty) {
        _selectedKelasList[index] = value;
      }
    });
  }

  void _updateSelectedGuru(UserModel? guru) {
    setState(() {
      if (guru != null) {
        _selectedGuruId = guru.id;
        _selectedGuruName = guru.nama;
      } else {
        _selectedGuruId = null;
        _selectedGuruName = null;
      }
    });
  }

  void _submitForm(AuthState state) {
    if (_formKey.currentState!.validate()) {
      // Validasi apakah guru sudah dipilih
      if (_selectedGuruId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih guru terlebih dahulu')),
        );
        return;
      }

      // Validasi apakah semua kelas sudah dipilih
      for (int i = 0; i < _selectedKelasList.length; i++) {
        if (_selectedKelasList[i].isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Harap pilih kelas untuk dropdown ke-${i + 1}')),
          );
          return;
        }
      }

      // Validasi duplikasi kelas
      final uniqueKelas = _selectedKelasList.toSet();
      if (uniqueKelas.length != _selectedKelasList.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terdapat kelas yang duplikat')),
        );
        return;
      }

      if (state is Authenticated) {
        // Kirim data untuk setiap kelas yang dipilih
        for (String kelas in _selectedKelasList) {
          if (!widget.isEdit) {
            context.read<KelasMengajarBloc>().add(
              CreateKelasMengajar(
                token: state.token,
                idUser: _selectedGuruId!,
                kelas: kelas,
                keyStatus: 'active',
              ),
            );
          } else {
            context.read<KelasMengajarBloc>().add(
              UpdateKelasMengajar(
                token: state.token,
                id: widget.kelasMengajarData!.id,
                idUser: _selectedGuruId!,
                kelas: kelas,
                keyStatus: 'active',
              ),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.isEdit
                    ? 'Kelas mengajar berhasil diupdate'
                    : '${_selectedKelasList.length} kelas mengajar berhasil ditambahkan untuk ${_selectedGuruName ?? "guru"}'
            ),
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Kelas Mengajar' : 'Tambah Kelas Mengajar'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informasi admin
                if (authState is Authenticated)

                // Dropdown Pilih Guru
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih Guru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BlocBuilder<UsersBloc, UsersState>(
                  builder: (context, userState) {
                    if (userState is UsersLoading) {
                      return const CircularProgressIndicator();
                    } else if (userState is UsersLoaded) {
                      final guruList = userState.users;

                      return DropdownButtonFormField<UserModel>(
                        value: _selectedGuruId == null
                            ? null
                            : guruList.firstWhere(
                              (guru) => guru.id == _selectedGuruId,
                          orElse: () => guruList.first,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Pilih Guru',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: [
                          const DropdownMenuItem<UserModel>(
                            value: null,
                            child: Text('Pilih Guru'),
                          ),
                          ...guruList.map((guru) {
                            return DropdownMenuItem<UserModel>(
                              value: guru,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    guru.nama,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    guru.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: _updateSelectedGuru,
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih guru terlebih dahulu';
                          }
                          return null;
                        },
                      );
                    } else if (userState is UsersError) {
                      return Text('Error: ${userState.message}');
                    } else {
                      return const Text('Tidak ada data guru');
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Info guru yang dipilih
                if (_selectedGuruId != null)
                  Card(
                    color: Colors.purple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Guru Terpilih: $_selectedGuruName',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('ID Guru: $_selectedGuruId'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Header section kelas
                Row(
                  children: [
                    const Icon(Icons.class_, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEdit ? 'Edit Kelas' : 'Pilih Kelas yang Diajar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  widget.isEdit
                      ? 'Anda dapat mengubah kelas yang diajar oleh guru ini'
                      : 'Tambahkan kelas yang akan diajar oleh guru. Anda dapat memilih multiple kelas.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                // List dropdown kelas
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedKelasList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedKelasList[index].isEmpty ? null : _selectedKelasList[index],
                              decoration: InputDecoration(
                                labelText: 'Kelas ${index + 1}',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.school),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Pilih Kelas'),
                                ),
                                ..._availableKelas.map((kelas) {
                                  return DropdownMenuItem<String>(
                                    value: kelas,
                                    child: Text('Kelas $kelas'),
                                  );
                                }),
                              ],
                              onChanged: (value) => _updateSelectedKelas(index, value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih kelas terlebih dahulu';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_selectedKelasList.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeKelasDropdown(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Tombol tambah kelas (hanya untuk tambah, bukan edit)
                if (!widget.isEdit)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kelas Lain'),
                    onPressed: _addKelasDropdown,
                  ),

                const SizedBox(height: 24),

                // Info jumlah kelas yang dipilih
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jumlah kelas yang dipilih: ${_selectedKelasList.where((kelas) => kelas.isNotEmpty).length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (_selectedGuruName != null)
                                Text(
                                  'Untuk guru: $_selectedGuruName',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol submit
                BlocConsumer<KelasMengajarBloc, KelasMengajarState>(
                  listener: (context, state) {
                    if (state is KelasMengajarError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is KelasMengajarLoading
                          ? null
                          : () => _submitForm(authState),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is KelasMengajarLoading
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Memproses...'),
                        ],
                      )
                          : Text(
                        widget.isEdit
                            ? 'Update Kelas Mengajar'
                            : 'Simpan Kelas Mengajar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),

                // Tombol batal
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}