import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_event.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_state.dart';

import '../bloc/auth/auth_state.dart';
import '../constants/color.dart';

class RapotSiswaScreen extends StatelessWidget {
  const RapotSiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Hitung lebar layar
    final screenWidth = MediaQuery.of(context).size.width;
    final authState = context.read<AuthBloc>().state;
    List<Map<String, dynamic>> rapot = [
      {
        "mata_pelajaran": "Bahasa Indonesia",
        "uts": "-",
        "uas": "-"
      },
      {
        "mata_pelajaran": "IPA",
        "uts": "-",
        "uas": "-"
      },
      {
        "mata_pelajaran": "Matematika",
        "uts": "-",
        "uas": "-"
      },
      {
        "mata_pelajaran": "TIK",
        "uts": "-",
        "uas": "-"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Rapot',
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Judul Rapot
            const Text(
              'RAPOT SISWA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Tabel
            BlocBuilder<HistoryUjianBloc, HistoryUjianState>(
              builder: (context, historyState){
                if(authState is! Authenticated){
                  return Text("Login Dulu min");
                }
                if(historyState is HistoryUjianInitial){
                  Future.microtask(() {
                    context.read<HistoryUjianBloc>().add(FetchHistoryUjianSiswa(
                        token: authState.token, userId: authState.id));
                  });
                }
                if(historyState is HistoryUjianLoading){
                  return Center(child: CircularProgressIndicator());
                }
                else if(historyState is HistoryUjianLoaded){
                  if(historyState.histories.isEmpty){
                    return Center(child: Text("Belum ada data tersedia"));
                  }
                  for (var history in historyState.histories) {
                    for(var temp in rapot){
                      if(history.ujian.mapel == temp["mata_pelajaran"]){
                        if(history.ujian.tipe_ujian == "UTS"){
                          temp["uts"] = history.nilai.toString();
                        }
                        else if(history.ujian.tipe_ujian == "UAS"){
                          temp["uas"] = history.nilai.toString();
                        }
                      }
                    }
                  }
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: screenWidth - 32, // Sesuaikan dengan padding
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: DataTable(
                          headingRowHeight: 60,
                          dataRowHeight: 50,
                          columnSpacing: 0, // Atur spasi kolom menjadi 0
                          horizontalMargin: 0, // Hilangkan margin horizontal
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            verticalInside: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          columns: [
                            DataColumn(
                              label: Container(
                                width: (screenWidth - 32) * 0.6, // 60% lebar untuk mata pelajaran
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                  'Mata Pelajaran',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                width: (screenWidth - 32) * 0.2, // 20% lebar untuk UTS
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: const Text(
                                  'UTS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Container(
                                width: (screenWidth - 32) * 0.2, // 20% lebar untuk UAS
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: const Text(
                                  'UAS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              numeric: true,
                            ),
                          ],
                          rows: rapot.map((data) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    width: (screenWidth - 32) * 0.6,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      data["mata_pelajaran"],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: (screenWidth - 32) * 0.2,
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Text(
                                      data["uts"],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: (screenWidth - 32) * 0.2,
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Text(
                                      data["uas"],
                                      style: const TextStyle(fontSize: 16),
                                    ),
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
                  return Text("Error");
                }
              }
            )
          ],
        ),
      ),
    );
  }
}