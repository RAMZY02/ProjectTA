import 'package:flutter/material.dart';

class HadiahScreen extends StatefulWidget {
  const HadiahScreen({super.key});

  @override
  State<HadiahScreen> createState() => _HadiahScreenState();
}

class _HadiahScreenState extends State<HadiahScreen> {
  // Data dummy user (biasanya dari API/database)
  int _userPoints = 1500;

  // Data dummy hadiah (biasanya dari API/database)
  final List<Map<String, dynamic>> _listHadiah = [
    {
      'id': 1,
      'nama': 'Pensil Mekanik',
      'gambar': 'https://cdn.pixabay.com/photo/2017/07/24/16/31/pencil-2536264_640.jpg',
      'poin': 300,
      'stok': 15,
      'kategori': 'Alat Tulis',
    },
    {
      'id': 2,
      'nama': 'Buku Catatan',
      'gambar': 'https://cdn.pixabay.com/photo/2016/11/23/00/32/notebook-1850603_640.jpg',
      'poin': 500,
      'stok': 8,
      'kategori': 'Alat Tulis',
    },
    {
      'id': 3,
      'nama': 'Paket Snack',
      'gambar': 'https://cdn.pixabay.com/photo/2016/03/05/22/18/food-1239241_640.jpg',
      'poin': 200,
      'stok': 20,
      'kategori': 'Jajanan',
    },
    {
      'id': 4,
      'nama': 'Susu Kotak',
      'gambar': 'https://cdn.pixabay.com/photo/2016/08/23/17/32/milk-1614828_640.jpg',
      'poin': 250,
      'stok': 12,
      'kategori': 'Minuman',
    },
    {
      'id': 5,
      'nama': 'Pulpen Premium',
      'gambar': 'https://cdn.pixabay.com/photo/2015/05/15/14/47/computer-768696_640.jpg',
      'poin': 800,
      'stok': 5,
      'kategori': 'Alat Tulis',
    },
  ];

  void _tukarHadiah(int hadiahId) {
    final hadiah = _listHadiah.firstWhere((h) => h['id'] == hadiahId);

    if (_userPoints < hadiah['poin']) {
      _showAlertDialog(
        'Poin Tidak Cukup',
        'Maaf, poin Anda tidak cukup untuk menukar hadiah ini. Anda membutuhkan ${hadiah['poin']} poin.',
      );
      return;
    }

    if (hadiah['stok'] <= 0) {
      _showAlertDialog(
        'Stok Habis',
        'Maaf, stok hadiah ini sudah habis.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Anda yakin ingin menukar ${hadiah['nama']} dengan ${hadiah['poin']} poin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Proses penukaran hadiah
              setState(() {
                _userPoints -= hadiah['poin'] as int; // Add explicit cast to int
                hadiah['stok'] = (hadiah['stok'] as int) - 1; // Also ensure stok is treated as int
              });
              Navigator.pop(context);
              _showSuccessDialog(hadiah['nama']);
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String namaHadiah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penukaran Berhasil'),
        content: Text('Anda berhasil menukar $namaHadiah. Hadiah dapat diambil di ruang guru.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Hadiah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Info Poin User
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Poin Anda:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  backgroundColor: Colors.blue[100],
                  label: Text(
                    '$_userPoints Poin',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Hadiah
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _listHadiah.length,
              itemBuilder: (context, index) {
                final hadiah = _listHadiah[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gambar Hadiah
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          hadiah['gambar'],
                          height: 250,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 250,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),

                      // Info Hadiah
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hadiah['nama'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.category, size: 16),
                                const SizedBox(width: 4),
                                Text(hadiah['kategori']),
                                const Spacer(),
                                const Icon(Icons.attach_money, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${hadiah['poin']} Poin',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.inventory, size: 16),
                                const SizedBox(width: 4),
                                Text('Stok: ${hadiah['stok']}'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tombol Tukar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _tukarHadiah(hadiah['id']),
                          child: const Text(
                            'TUKAR SEKARANG',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}