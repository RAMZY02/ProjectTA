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
                onPressed: () async {
                  final result = await Navigator.push(
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
                  if (commentState is! CommentsLoaded || commentState.comments.isEmpty || commentState
                  is CommentsInitial) {
                    Future.microtask(() {
                      context.read<CommentsBloc>().add(FetchAllComments(token: authState.token));
                    });
                  }
                  if(commentState is CommentsLoaded){
                    return SingleChildScrollView(
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
                          rows: commentState.comments.map((comment) {
                            return DataRow(
                              cells: [
                                DataCell(Text(comment.id.toString())),
                                DataCell(Text(comment.idVideo.toString())),
                                DataCell(Text(comment.user.nama)),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 200),
                                    child: Text(
                                      comment.komentar,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(comment.likes.toString())),
                                DataCell(Text(comment.waktu.toString().substring(0, 16))),
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
                    );
                  }
                  else{
                    return CircularProgressIndicator();
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