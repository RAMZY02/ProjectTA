import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/bloc/users/users_state.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/pemeriksaan_jawaban_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/ujian/ujian_bloc.dart';
import '../bloc/ujian/ujian_event.dart';

class DaftarSiswaScreen extends StatefulWidget {
  final UjianModel ujian;

  const DaftarSiswaScreen({super.key, required this.ujian});

  @override
  State<DaftarSiswaScreen> createState() => _DaftarSiswaScreenState();
}

class _DaftarSiswaScreenState extends State<DaftarSiswaScreen> {
  List<dynamic> filteredUsers = [];
  String selectedClass = '';
  List<String> classes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterUsers);
    context.read<UsersBloc>().add(Init());
    context.read<UjianBloc>().add(InitUjian());
    if (widget.ujian.tingkatan != '' && widget.ujian.tingkatan != '-') {
      selectedClass = widget.ujian.tingkatan == '9'
          ? '9A'
          : widget.ujian.tingkatan == '8'
          ? '8A'
          : '7A';
      classes = widget.ujian.tingkatan == '9'
          ? ['9A', '9B', '9C', '9D', '9E', '9F', '9G', '9H', '9I', '9J']
          : widget.ujian.tingkatan == '8'
          ? ['8A', '8B', '8C', '8D', '8E', '8F', '8G', '8H', '8I', '8J']
          : ['7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J'];
    } else if (widget.ujian.kelas != '' && widget.ujian.kelas != '-') {
      selectedClass = widget.ujian.kelas;
      classes = [widget.ujian.kelas];
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final usersState = context.read<UsersBloc>().state;
    if (usersState is UsersLoaded) {
      final searchTerm = searchController.text.toLowerCase();
      setState(() {
        filteredUsers = usersState.users.where((user) {
          final userName = user.nama.toLowerCase();
          return userName.contains(searchTerm);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    context.read<SoalUjianBloc>().add(InitSoalUjian());

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Siswa - ${widget.ujian.nama}'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama siswa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _filterUsers();
                  },
                )
                    : null,
              ),
            ),
          ),

          // Class selector navbar
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final className = classes[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: Text(className),
                    selected: selectedClass == className,
                    onSelected: (selected) {
                      context.read<UsersBloc>().add(Init());
                      searchController.clear(); // Clear search when changing class
                      setState(() {
                        selectedClass = className;
                        filteredUsers.clear();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // Student list
          BlocBuilder<UsersBloc, UsersState>(
            builder: (context, usersState) {
              if (authState is Authenticated && usersState is UsersInitial) {
                context.read<UsersBloc>().add(FetchUsersByKelasAndUjian(
                    token: authState.token,
                    kelas: selectedClass,
                    id_ujian: widget.ujian.id));
              }

              if (usersState is UsersLoaded) {
                // Initialize filteredUsers if empty
                if (filteredUsers.isEmpty && searchController.text.isEmpty) {
                  filteredUsers = List.from(usersState.users);
                } else if (searchController.text.isNotEmpty) {
                  // Filter users based on search
                  final searchTerm = searchController.text.toLowerCase();
                  filteredUsers = usersState.users.where((user) {
                    final userName = user.nama.toLowerCase();
                    return userName.contains(searchTerm);
                  }).toList();
                }

                if (filteredUsers.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ditemukan siswa dengan nama tersebut',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final student = filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(student.nama),
                          trailing: student.diperiksa == 'true'
                              ? Text(
                            'Nilai: ${student.nilai}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          )
                              : const Text(
                            'Belum dinilai',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            context
                                .read<SoalUjianBloc>()
                                .add(InitSoalUjian());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PemeriksaanJawabanScreen(
                                      examData: widget.ujian,
                                      student: student,
                                      studentClass: selectedClass,
                                    ),
                              ),
                            ).then((value) {
                              // This will be called when returning from PemeriksaanJawabanScreen
                              if (value != null) {
                                setState(() {
                                  // Update the student's score
                                  student.nilai = value;
                                });
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              } else if (usersState is UsersLoading) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (usersState is UsersError) {
                return Expanded(
                  child: Center(child: Text(usersState.message)),
                );
              } else {
                return const Expanded(child: Center(child: Text("")));
              }
            },
          ),
        ],
      ),
    );
  }
}