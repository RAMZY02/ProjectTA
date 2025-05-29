import 'package:flutter/material.dart';
import 'insert_video_edukasi_screen.dart';

class MasterVideoEdukasiScreen extends StatefulWidget {
  const MasterVideoEdukasiScreen({super.key});

  @override
  State<MasterVideoEdukasiScreen> createState() => _MasterVideoEdukasiScreenState();
}

class _MasterVideoEdukasiScreenState extends State<MasterVideoEdukasiScreen> {
  // Sample Data Video Edukasi
  List<Map<String, dynamic>> _videos = [
    {
      'id': 1,
      'judul': 'Matematika Dasar',
      'link_video': 'https://example.com/video1',
      'deskripsi': 'Pembelajaran matematika dasar untuk pemula',
      'likes': 120,
      'mata_pelajaran': 'Matematika',
      'views': 1500,
      'kelas': '7'
    },
    {
      'id': 2,
      'judul': 'Fisika Modern',
      'link_video': 'https://example.com/video2',
      'deskripsi': 'Konsep-konsep fisika modern',
      'likes': 85,
      'mata_pelajaran': 'Fisika',
      'views': 980,
      'kelas': '9'
    },
  ];

  void _deleteVideo(int id) {
    setState(() {
      _videos.removeWhere((video) => video['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Video'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertVideoEdukasiScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      result['id'] = _videos.isEmpty ? 1 : _videos.last['id'] + 1;
                      _videos.add(result);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // DataTable
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Judul')),
                      DataColumn(label: Text('Mata Pelajaran')),
                      DataColumn(label: Text('Kelas')),
                      DataColumn(label: Text('Views'), numeric: true),
                      DataColumn(label: Text('Likes'), numeric: true),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _videos.map((video) {
                      return DataRow(
                        cells: [
                          DataCell(Text(video['id'].toString())),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                video['judul'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(video['mata_pelajaran'])),
                          DataCell(Text('Kelas ${video['kelas']}')),
                          DataCell(Text(video['views'].toString())),
                          DataCell(Text(video['likes'].toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InsertVideoEdukasiScreen(
                                          videoData: video,
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        final index = _videos.indexWhere((v) => v['id'] == video['id']);
                                        if (index != -1) {
                                          _videos[index] = result;
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteVideo(video['id']),
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
            ),
          ],
        ),
      ),
    );
  }
}