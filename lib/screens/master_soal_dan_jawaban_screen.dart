import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/models/ujian_model.dart';
import 'package:project_ta/screens/insert_soal_dan_jawaban_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/soal_ujian/soal_ujian_state.dart';

class MasterSoalDanJawabanScreen extends StatefulWidget {
  final UjianModel ujian;

  const MasterSoalDanJawabanScreen({
    super.key,
    required this.ujian,
  });

  @override
  State<MasterSoalDanJawabanScreen> createState() => _MasterSoalDanJawabanScreenState();
}

class _MasterSoalDanJawabanScreenState extends State<MasterSoalDanJawabanScreen> {

  @override
  void initState() {
    super.initState();
  }

  void _deleteSoal(int id, int idUjian, String token) {
    context.read<SoalUjianBloc>().add(DeleteSoal(token: token, id: id, id_ujian: idUjian));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Soal berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Soal - ${widget.ujian.nama}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Soal'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsertSoalDanJawabanScreen(
                        idUjian: widget.ujian.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SoalUjianBloc, SoalUjianState>(
                builder: (context, soalUjianState){
                  if(authState is! Authenticated){
                    return Text("Login Dulu min");
                  }
                  if (soalUjianState is SoalUjianInitial) {
                    Future.microtask(() {
                      context.read<SoalUjianBloc>().add(FetchSoalUjian2(token: authState.token, ujianId: widget.ujian.id));
                    });
                  }
                  if(soalUjianState is SoalUjianLoaded){
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Tipe')),
                            DataColumn(label: Text('Soal')),
                            DataColumn(label: Text('Opsi A')),
                            DataColumn(label: Text('Opsi B')),
                            DataColumn(label: Text('Opsi C')),
                            DataColumn(label: Text('Opsi D')),
                            DataColumn(label: Text('Opsi E')),
                            DataColumn(label: Text('Jawaban')),
                            DataColumn(label: Text('Pembahasan')),
                            DataColumn(label: Text('Link Video')),
                            DataColumn(label: Text('Link Gambar')),
                            DataColumn(label: Text('Link Audio')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: soalUjianState.soalList.map((soal) {
                            return DataRow(
                              cells: [
                                DataCell(Text(soal.id.toString())),
                                DataCell(Text(soal.tipe)),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: Text(soal.soal),
                                  ),
                                ),
                                // Show "-" for options if not Pilihan Ganda
                                DataCell(Text(soal.tipe == 'Pilihan Ganda' ? soal.opsiA : '-')),
                                DataCell(Text(soal.tipe == 'Pilihan Ganda' ? soal.opsiB : '-')),
                                DataCell(Text(soal.tipe == 'Pilihan Ganda' ? soal.opsiC : '-')),
                                DataCell(Text(soal.tipe == 'Pilihan Ganda' ? soal.opsiD : '-')),
                                DataCell(Text(soal.tipe == 'Pilihan Ganda' ? soal.opsiE : '-')),
                                DataCell(Text(soal.jawaban)),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: Text(soal.pembahasan),
                                  ),
                                ),
                                DataCell(Text(soal.linkVideo != '-' ? soal.linkVideo : '-')),
                                DataCell(Text(soal.linkGambar != '-' ? soal.linkGambar : '-')),
                                DataCell(Text(soal.linkAudio != '-' ? soal.linkAudio : '-')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InsertSoalDanJawabanScreen(
                                                soalData: soal,
                                                isEdit: true,
                                              ),
                                            ),
                                          );

                                          if (result != null) {
                                            setState(() {
                                              final index = soalUjianState.soalList.indexWhere((s) => s.id == soal.id);
                                              if (index != -1) {
                                                soalUjianState.soalList[index] = result;
                                              }
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteSoal(soal.id, widget.ujian.id, authState.token),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                  else if(soalUjianState is SoalUjianNotFound){
                    return Center(child: Text("Belum ada data tersedia"));
                  }
                  else{
                    return CircularProgressIndicator();
                  }
                }
              )
            ),
          ],
        ),
      ),
    );
  }
}