import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
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
            ),
            const SizedBox(height: 16),
            // DataTable
            Expanded(
                child: BlocBuilder<CommentsBloc, CommentsState>(
                    builder: (context, commentState){
                      if(authState is! Authenticated){
                        return Text("Login Dulu min");
                      }
                      if (commentState is CommentsInitial) {
                        Future.microtask(() {
                          context.read<CommentsBloc>().add(FetchAllComments(token: authState.token));
                        });
                      }
                      if(commentState is CommentsLoaded){
                        if(commentState.comments.isEmpty){
                          return Center(child: Text("Belum ada data tersedia"));
                        }
                        return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              // Enable mouse drag
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
                                  DataColumn(label: Text('Likes'), numeric: true),
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
                                rows: commentState.comments.map((comment) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(comment.id.toString())),
                                      DataCell(Center(child: Text(comment.idVideo.toString()))),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 120),
                                          child: Text(
                                            comment.user.nama,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(
                                            comment.komentar,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(Center(child: Text(comment.likes.toString()))),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            comment.waktu.toString().substring(0, 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
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
                                              icon: const Icon(Icons.delete, color: Colors.red),
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
                        );
                      }
                      else{
                        return Center(child: CircularProgressIndicator());
                      }
                    }
                )
            ),
          ],
        ),
      ),
    );
  }
}