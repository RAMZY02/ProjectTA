import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_bloc.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_event.dart';
import 'package:project_ta/bloc/history_ujian/history_ujian_state.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_bloc.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_event.dart';
import 'package:project_ta/bloc/mata_pelajaran/mata_pelajaran_state.dart';

import '../bloc/auth/auth_state.dart';
import '../constants/color.dart';

class RapotSiswaScreen extends StatelessWidget {
  const RapotSiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authState = context.read<AuthBloc>().state;

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

            // MultiBlocProvider untuk handle kedua bloc
            MultiBlocListener(
              listeners: [
                BlocListener<MataPelajaranBloc, MataPelajaranState>(
                  listener: (context, mapelState) {
                    // Jika mata pelajaran sudah loaded, fetch history ujian
                    if (mapelState is MataPelajaranLoaded && authState is Authenticated) {
                      context.read<HistoryUjianBloc>().add(FetchHistoryUjianSiswa(
                          token: authState.token,
                          userId: authState.id
                      ));
                    }
                  },
                ),
              ],
              child: BlocBuilder<MataPelajaranBloc, MataPelajaranState>(
                builder: (context, mapelState) {
                  return BlocBuilder<HistoryUjianBloc, HistoryUjianState>(
                    builder: (context, historyState) {
                      // Cek authentication
                      if (authState is! Authenticated) {
                        return const Expanded(
                          child: Center(
                            child: Text("Silakan login terlebih dahulu"),
                          ),
                        );
                      }

                      // Handle loading state untuk mata pelajaran
                      if (mapelState is MataPelajaranInitial) {
                        context.read<MataPelajaranBloc>().add(FetchMataPelajaranSiswa(
                            id_user: authState.id,
                            token: authState.token
                        ));
                        return const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (mapelState is MataPelajaranLoading) {
                        return const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (mapelState is MataPelajaranError) {
                        return Expanded(
                          child: Center(
                            child: Text('Error: ${mapelState.message}'),
                          ),
                        );
                      }

                      // Jika mata pelajaran sudah loaded
                      if (mapelState is MataPelajaranLoaded) {
                        // Generate list rapor dari data mata pelajaran
                        List<Map<String, dynamic>> rapot = _generateRapotFromMapel(mapelState.mataPelajaranList);

                        // Handle loading state untuk history ujian
                        if (historyState is HistoryUjianLoading) {
                          return const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Jika history ujian sudah loaded, update nilai
                        if (historyState is HistoryUjianLoaded) {
                          _updateNilaiRapot(rapot, historyState.histories);
                        }

                        // Tampilkan tabel rapor
                        return Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              width: screenWidth - 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              child: _buildRapotTable(rapot),
                            ),
                          ),
                        );
                      }

                      // Fallback
                      return const Expanded(
                        child: Center(
                          child: Text("Terjadi kesalahan"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk generate rapor dari data mata pelajaran
  List<Map<String, dynamic>> _generateRapotFromMapel(List<dynamic> mataPelajaranList) {
    return mataPelajaranList.map((mapel) {
      return {
        "mata_pelajaran": mapel.mapel,
        "uts": "-",
        "uas": "-"
      };
    }).toList();
  }

  // Fungsi untuk update nilai UTS dan UAS berdasarkan history
  void _updateNilaiRapot(List<Map<String, dynamic>> rapot, List<dynamic> histories) {
    for (var history in histories) {
      for (var mapel in rapot) {
        if (history.ujian.mapel == mapel["mata_pelajaran"]) {
          if (history.ujian.tipe_ujian == "UTS") {
            mapel["uts"] = history.nilai.toString();
          } else if (history.ujian.tipe_ujian == "UAS") {
            mapel["uas"] = history.nilai.toString();
          }
        }
      }
    }
  }

  // Fungsi untuk membangun tabel rapor
  Widget _buildRapotTable(List<Map<String, dynamic>> rapot) {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey, width: 1),
        verticalInside: BorderSide(color: Colors.grey, width: 1),
        top: BorderSide(color: Colors.grey, width: 1),
        bottom: BorderSide(color: Colors.grey, width: 1),
        left: BorderSide(color: Colors.grey, width: 1),
        right: BorderSide(color: Colors.grey, width: 1),
      ),
      columnWidths: {
        0: FlexColumnWidth(0.6),
        1: FlexColumnWidth(0.2),
        2: FlexColumnWidth(0.2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header Row
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Mata Pelajaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'UTS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'UAS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        // Data Rows
        ...rapot.map((data) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data["mata_pelajaran"],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data["uts"],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data["uas"],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}