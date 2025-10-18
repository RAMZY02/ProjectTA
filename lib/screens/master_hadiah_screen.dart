import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_event.dart';
import 'package:project_ta/bloc/hadiah/hadiah_state.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_hadiah_screen.dart';

class MasterHadiahScreen extends StatefulWidget {
  const MasterHadiahScreen({super.key});

  @override
  State<MasterHadiahScreen> createState() => _MasterHadiahScreenState();
}

class _MasterHadiahScreenState extends State<MasterHadiahScreen> {

  void _deleteHadiah(int id, String token) {
    context.read<HadiahBloc>().add(DeleteHadiah(token: token, hadiahId: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hadiah berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Hadiah'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InsertHadiahScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
              child: BlocBuilder<HadiahBloc, HadiahState>(
                  builder: (context, hadiahState){
                    if(authState is! Authenticated){
                      return Text("Login Dulu min");
                    }
                    if (hadiahState is HadiahInitial) {
                      context.read<HadiahBloc>().add(FetchHadiah(token: authState.token));
                    }
                    if(hadiahState is HadiahLoaded){
                      if(hadiahState.hadiah.isEmpty){
                        return Center(child: Text("Belum ada data tersedia"));
                      }
                      return ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            // Enable mouse drag
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Nama Hadiah')),
                                DataColumn(label: Text('Poin'), numeric: true),
                                DataColumn(label: Text('Stok'), numeric: true),
                                DataColumn(label: Text('Link Gambar')),
                                DataColumn(label: Text('Kategori')),
                                DataColumn(
                                  label: SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text('Aksi'),
                                    ),
                                  ),
                                ),
                              ],
                              rows: hadiahState.hadiah.map((hadiah) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(hadiah.id.toString())),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 150),
                                        child: Text(
                                          hadiah.nama,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Center(child: Text(hadiah.poin.toString()))),
                                    DataCell(Center(child: Text(hadiah.stok.toString()))),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 200),
                                        child: Text(
                                          hadiah.link_gambar,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 120),
                                        child: Text(
                                          hadiah.kategori,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => InsertHadiahScreen(
                                                    hadiahData: hadiah,
                                                  ),
                                                ),
                                              );

                                              if (result != null) {
                                                setState(() {
                                                  final index = hadiahState.hadiah.indexWhere((h) => h.id == hadiah.id);
                                                  if (index != -1) {
                                                    hadiahState.hadiah[index] = result;
                                                  }
                                                });
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteHadiah(hadiah.id, authState.token),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    }
                    else{
                      return Center(child: CircularProgressIndicator());
                    }
                  }
              )
          ),
        ],
      ),
    );
  }
}