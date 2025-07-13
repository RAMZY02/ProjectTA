import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/color.dart';

class RapotSiswaScreen extends StatelessWidget {
  const RapotSiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy rapor
    final List<Map<String, dynamic>> reportData = [
      {'subject': 'Matematika', 'uts': 85, 'uas': 90},
      {'subject': 'Bahasa Indonesia', 'uts': 78, 'uas': 82},
      {'subject': 'IPA', 'uts': 92, 'uas': 94},
      {'subject': 'IPS', 'uts': 80, 'uas': 83},
    ];

    // Hitung lebar layar
    final screenWidth = MediaQuery.of(context).size.width;

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
            Expanded(
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
                    rows: reportData.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: (screenWidth - 32) * 0.6,
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                data['subject'],
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
                                data['uts'].toString(),
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
                                data['uas'].toString(),
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
            ),
          ],
        ),
      ),
    );
  }
}