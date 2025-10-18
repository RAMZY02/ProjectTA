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

  String selectedClass = '';
  List<String> classes = [];

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(Init());
    context.read<UjianBloc>().add(InitUjian());
    if(widget.ujian.tingkatan != '' && widget.ujian.tingkatan != '-'){
      selectedClass = widget.ujian.tingkatan == '9' ? '9A' : widget.ujian.tingkatan == '8' ? '8A' : '7A' ;
      classes = widget.ujian.tingkatan == '9' ? ['9A', '9B', '9C', '9D', '9E', '9F', '9G', '9H', '9I', '9J'] : widget.ujian.tingkatan == '8' ? ['8A', '8B', '8C', '8D', '8E', '8F', '8G', '8H', '8I', '8J'] : ['7A', '7B', '7C', '7D', '7E', '7F', '7G', '7H', '7I', '7J'] ;
    }
    else if(widget.ujian.kelas != '' && widget.ujian.kelas != '-'){
      selectedClass = widget.ujian.kelas;
      classes = [widget.ujian.kelas];
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
                      setState(() {
                        selectedClass = className;
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
            builder: (context, usersState){
              if (authState is Authenticated && usersState is UsersInitial) {
                Future.microtask(() {
                  context.read<UsersBloc>().add(FetchUsersByKelasAndUjian(token: authState.token, kelas: selectedClass, id_ujian: widget.ujian.id));
                });
              }

              if(usersState is UsersLoaded){
                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: usersState.users.length,
                    itemBuilder: (context, index) {
                      final student = usersState.users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(student.nama),
                          trailing: student.diperiksa
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PemeriksaanJawabanScreen(examData: widget.ujian, student: student, studentClass: selectedClass)
                                )
                            ).then((value) {
                              // This will be called when returning from PemeriksaanJawabanScreen
                              if (value != null) {
                                setState(() {
                                  // Update the student's score
                                  // studentsByClass[selectedClass]![index]['score'] = value;
                                });
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              }
              else if (usersState is UsersLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              else if (usersState is UsersError) {
                return Center(child: Text(usersState.message));
              }
              else {
                return const Center(child: Text(""));
              }
            }
          )
        ],
      ),
    );
  }
}