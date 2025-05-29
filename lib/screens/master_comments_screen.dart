import 'package:flutter/material.dart';
import 'insert_comment_screen.dart';

class MasterCommentsScreen extends StatefulWidget {
  const MasterCommentsScreen({super.key});

  @override
  State<MasterCommentsScreen> createState() => _MasterCommentsScreenState();
}

class _MasterCommentsScreenState extends State<MasterCommentsScreen> {
  // Sample Data Komentar
  List<Map<String, dynamic>> _comments = [
    {
      'id': 1,
      'id_video': 101,
      'comment': 'Video ini sangat membantu!',
      'id_user': 1001,
      'likes': 24,
      'time_stamp': '2023-05-15 14:30:22',
      'user_name': 'John Doe' // tambahan untuk display
    },
    {
      'id': 2,
      'id_video': 101,
      'comment': 'Bagian penjelasan di menit 5:30 kurang jelas',
      'id_user': 1002,
      'likes': 5,
      'time_stamp': '2023-05-16 09:15:10',
      'user_name': 'Jane Smith'
    },
    {
      'id': 3,
      'id_video': 102,
      'comment': 'Terima kasih untuk videonya!',
      'id_user': 1003,
      'likes': 12,
      'time_stamp': '2023-05-17 16:45:33',
      'user_name': 'Bob Johnson'
    },
  ];

  // Dummy list video untuk dropdown
  final List<Map<String, dynamic>> _videos = [
    {'id': 101, 'title': 'Matematika Dasar'},
    {'id': 102, 'title': 'Fisika Modern'},
  ];

  // Dummy list user untuk dropdown
  final List<Map<String, dynamic>> _users = [
    {'id': 1001, 'name': 'John Doe'},
    {'id': 1002, 'name': 'Jane Smith'},
    {'id': 1003, 'name': 'Bob Johnson'},
  ];

  void _deleteComment(int id) {
    setState(() {
      _comments.removeWhere((comment) => comment['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Komentar berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Komentar'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertCommentScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      result['id'] = _comments.isEmpty ? 1 : _comments.last['id'] + 1;
                      result['time_stamp'] = DateTime.now().toString();
                      _comments.add(result);
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
                      DataColumn(label: Text('Video')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Komentar')),
                      DataColumn(label: Text('Likes'), numeric: true),
                      DataColumn(label: Text('Waktu')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _comments.map((comment) {
                      final video = _videos.firstWhere(
                              (v) => v['id'] == comment['id_video'],
                          orElse: () => {'title': 'Unknown'});

                      return DataRow(
                        cells: [
                          DataCell(Text(comment['id'].toString())),
                          DataCell(Text(video['title'])),
                          DataCell(Text(comment['user_name'] ?? 'Unknown')),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                comment['comment'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(comment['likes'].toString())),
                          DataCell(Text(comment['time_stamp'].toString().substring(0, 16))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InsertCommentScreen(
                                          commentData: comment,
                                          videos: _videos,
                                          users: _users,
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      setState(() {
                                        final index = _comments.indexWhere((c) => c['id'] == comment['id']);
                                        if (index != -1) {
                                          _comments[index] = {
                                            ..._comments[index],
                                            ...result,
                                            'id': comment['id'], // Pertahankan ID asli
                                          };
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteComment(comment['id']),
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