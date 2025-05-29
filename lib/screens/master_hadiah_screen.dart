import 'package:flutter/material.dart';
import 'insert_hadiah_screen.dart'; // Anda perlu membuat file ini nanti

class MasterHadiahScreen extends StatefulWidget {
  const MasterHadiahScreen({super.key});

  @override
  State<MasterHadiahScreen> createState() => _MasterHadiahScreenState();
}

class _MasterHadiahScreenState extends State<MasterHadiahScreen> {
  // Sample Data Hadiah
  List<Map<String, dynamic>> _hadiah = [
    {'id': 1, 'nama': 'Voucher Belanja Rp 50.000', 'poin': 500, 'stok': 10},
    {'id': 2, 'nama': 'Tumbler Premium', 'poin': 300, 'stok': 15},
    {'id': 3, 'nama': 'Payung Cantik', 'poin': 200, 'stok': 8},
  ];

  void _deleteHadiah(int id) {
    setState(() {
      _hadiah.removeWhere((hadiah) => hadiah['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hadiah berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                if (result != null) {
                  setState(() {
                    // Tambah hadiah baru dengan ID increment
                    result['id'] = _hadiah.isEmpty ? 1 : _hadiah.last['id'] + 1;
                    _hadiah.add(result);
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          // DataTable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Nama Hadiah')),
                  DataColumn(label: Text('Poin'), numeric: true),
                  DataColumn(label: Text('Stok'), numeric: true),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: _hadiah.map((hadiah) {
                  return DataRow(
                    cells: [
                      DataCell(Text(hadiah['id'].toString())),
                      DataCell(Text(hadiah['nama'])),
                      DataCell(Text(hadiah['poin'].toString())),
                      DataCell(Text(hadiah['stok'].toString())),
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
                                    final index = _hadiah.indexWhere((h) => h['id'] == hadiah['id']);
                                    if (index != -1) {
                                      _hadiah[index] = result;
                                    }
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteHadiah(hadiah['id']),
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
        ],
      ),
    );
  }
}