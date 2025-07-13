import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_bloc.dart';
import 'package:project_ta/bloc/hadiah/hadiah_event.dart';
import 'package:project_ta/bloc/hadiah/hadiah_state.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_hadiah_screen.dart'; // Anda perlu membuat file ini nanti

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
              onPressed: () async {
                final result = await Navigator.push(
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
                if (hadiahState is! HadiahLoaded || hadiahState.hadiah.isEmpty || hadiahState
                is HadiahInitial) {
                  Future.microtask(() {
                    context.read<HadiahBloc>().add(FetchHadiah(token: authState.token));
                  });
                }
                if(hadiahState is HadiahLoaded){
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama Hadiah')),
                        DataColumn(label: Text('Poin'), numeric: true),
                        DataColumn(label: Text('Stok'), numeric: true),
                        DataColumn(label: Text('Link Gambar')),
                        DataColumn(label: Text('Kategori')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: hadiahState.hadiah.map((hadiah) {
                        return DataRow(
                          cells: [
                            DataCell(Text(hadiah.id.toString())),
                            DataCell(Text(hadiah.nama)),
                            DataCell(Text(hadiah.poin.toString())),
                            DataCell(Text(hadiah.stok.toString())),
                            DataCell(Text(hadiah.link_gambar)),
                            DataCell(Text(hadiah.kategori)),
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
                                            hadiahData: hadiah, // Data hadiah yang akan diedit
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
                  );
                }
                else{
                  return CircularProgressIndicator();
                }
              }
            )
          ),
        ],
      ),
    );
  }
}