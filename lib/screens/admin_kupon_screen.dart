import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/color.dart';

class AdminKuponScreen extends StatelessWidget {
  const AdminKuponScreen({super.key});

  final List<Map<String, dynamic>> _list_kupon = const [
    {
      "id" : 1,
      "nama_hadiah" : "buku tulis",
      "kode" : "AT_001_16042025",
      "status" : "Unclaimed"
    },
    {
      "id" : 2,
      "nama_hadiah" : "buku gambar",
      "kode" : "AT_002_16042025",
      "status" : "Claimed"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Kupon",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,// Custom shadow color
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: _list_kupon.isEmpty
          ? const Center(
        child: Text('Tidak ada kupon yang tersedua'),
      )
          : ListView.builder(
        itemCount: _list_kupon.length,
        itemBuilder: (context, index) {
          final kupon = _list_kupon[index];
          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo Mata Pelajaran
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      kupon['id'].toString(),
                      style: TextStyle(
                        fontSize: 36,
                      ),
                    )
                  ),
                  const SizedBox(width: 16),
                  // Konten Ujian
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kupon['nama_hadiah'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kupon['kode'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    kupon["status"],
                    style: TextStyle(
                      fontSize: 18,
                      color: kupon['status'] == "Claimed" ? Colors.green : Colors.grey
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
