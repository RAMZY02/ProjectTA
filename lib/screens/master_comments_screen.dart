import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/comments/comments_event.dart';
import 'package:project_ta/bloc/comments/comments_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'insert_comment_screen.dart';

class MasterCommentsScreen extends StatefulWidget {
  const MasterCommentsScreen({super.key});

  @override
  State<MasterCommentsScreen> createState() => _MasterCommentsScreenState();
}

class _MasterCommentsScreenState extends State<MasterCommentsScreen> {
  // Tambahkan controller untuk search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk filter komentar berdasarkan query
  List<dynamic> _filterComments(List<dynamic> commentsList, String query) {
    if (query.isEmpty) return commentsList;

    return commentsList.where((comment) {
      return comment.user.nama.toLowerCase().contains(query) ||
          comment.komentar.toLowerCase().contains(query) ||
          comment.idVideo.toString().contains(query) ||
          comment.likes.toString().contains(query);
    }).toList();
  }

  // Fungsi untuk format waktu - DIPERBAIKI untuk handle berbagai tipe data
  String _formatWaktu(dynamic waktu) {
    try {
      DateTime dateTime;

      // Handle jika waktu adalah String
      if (waktu is String) {
        dateTime = DateTime.parse(waktu);
      }
      // Handle jika waktu adalah DateTime
      else if (waktu is DateTime) {
        dateTime = waktu;
      }
      // Jika tipe data lain, kembalikan string asli
      else {
        return waktu.toString();
      }

      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return DateFormat('d MMM yyyy').format(dateTime);
      }
    } catch (e) {
      // Jika parsing gagal, kembalikan string asli atau default
      if (waktu is String) {
        return waktu.length > 16 ? waktu.substring(0, 16) : waktu;
      }
      return waktu.toString();
    }
  }

  void _deleteComment(int id, AuthState state) {
    if(state is Authenticated){
      context.read<CommentsBloc>().add(DeleteComment(token: state.token, id_comment: id));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Komentar berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row untuk Search Bar dan Add Button
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari komentar berdasarkan nama user, isi komentar...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Komentar'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsertCommentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DataTable
            Expanded(
              child: BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, commentState) {
                  if (authState is! Authenticated) {
                    return const Center(child: Text("Silakan login terlebih dahulu"));
                  }
                  if (commentState is CommentsInitial) {
                    context.read<CommentsBloc>().add(FetchAllComments(token: authState.token));
                  }
                  if (commentState is CommentsLoaded) {
                    // Filter komentar berdasarkan search query
                    var filteredComments = _filterComments(commentState.comments, _searchQuery);

                    if (filteredComments.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.comment, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? "Belum ada komentar tersedia"
                                : "Tidak ditemukan komentar dengan kata kunci '$_searchQuery'",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    // Tampilkan info filter
                    Widget filterInfo = Container();
                    if (_searchQuery.isNotEmpty) {
                      filterInfo = Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filteredComments.length} dari ${commentState.comments.length} komentar',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('Hapus Pencarian'),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        filterInfo,
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 20,
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('ID Video')),
                                    DataColumn(label: Text('User')),
                                    DataColumn(label: Text('Komentar')),
                                    DataColumn(label: Text('Likes')),
                                    DataColumn(label: Text('Waktu')),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 100,
                                        child: Center(
                                          child: Text('Aksi'),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: filteredComments.map((comment) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            comment.id.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              comment.idVideo.toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.person,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 100),
                                                  child: Text(
                                                    comment.user.nama,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 200),
                                              child: Text(
                                                comment.komentar,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.thumb_up,
                                                    size: 14, color: Colors.pink),
                                                const SizedBox(width: 4),
                                                Text(
                                                  comment.likes.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.pink[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              _formatWaktu(comment.waktu),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue, size: 20),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => InsertCommentScreen(
                                                        commentData: comment,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red, size: 20),
                                                onPressed: () => _deleteComment(comment.id, authState),
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
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}