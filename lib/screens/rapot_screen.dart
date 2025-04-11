import 'package:flutter/material.dart';

class RapotScreen extends StatelessWidget {

  const RapotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy rapor
    final List<Map<String, dynamic>> reportData = [
      {'subject': 'Matematika', 'uts': 85, 'uas': 90},
      {'subject': 'Bahasa Indonesia', 'uts': 78, 'uas': 82},
      {'subject': 'Bahasa Inggris', 'uts': 88, 'uas': 85},
      {'subject': 'IPA', 'uts': 92, 'uas': 94},
      {'subject': 'IPS', 'uts': 80, 'uas': 83},
      {'subject': 'PPKn', 'uts': 85, 'uas': 87},
      {'subject': 'Seni Budaya', 'uts': 90, 'uas': 91},
      {'subject': 'PJOK', 'uts': 87, 'uas': 89},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Rapot'),
      ),
      body: Align(
        alignment: Alignment.topCenter, // Posisi di tengah atas
        child: Padding(
          padding: const EdgeInsets.only(top: 20), // Jarak dari atas
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30, // Spasi antar kolom
              horizontalMargin: 20, // Margin horizontal
              columns: const [
                DataColumn(
                  label: Text(
                    'Mata Pelajaran',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'UTS',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'UAS',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
              ],
              rows: reportData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                            data['subject'],
                            style: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                            data['uts'].toString(),
                            style: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                            data['uas'].toString(),
                            style: TextStyle(fontSize: 20)
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
    );
  }
}