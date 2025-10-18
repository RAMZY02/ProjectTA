import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/comments/comments_event.dart';
import 'package:project_ta/models/comment_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/users/users_bloc.dart';
import '../bloc/users/users_event.dart';
import '../bloc/users/users_state.dart';
import '../bloc/video_edukasi/video_edukasi_bloc.dart';
import '../bloc/video_edukasi/video_edukasi_event.dart';
import '../bloc/video_edukasi/video_edukasi_state.dart';
import '../models/user_model.dart';
import '../models/video_edukasi_model.dart';

class InsertCommentScreen extends StatefulWidget {
  final CommentModel? commentData;

  bool get isEdit => commentData != null;

  const InsertCommentScreen({
    super.key,
    this.commentData,
  });

  @override
  State<InsertCommentScreen> createState() => _InsertCommentScreenState();
}

class _InsertCommentScreenState extends State<InsertCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  late int? _selectedVideoId;
  late int? _selectedUserId;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _selectedVideoId = widget.commentData?.idVideo;
    _selectedUserId = widget.commentData?.user.id;
    _commentController = TextEditingController(text: widget.commentData?.komentar ?? '');

    // Fetch users and videos data when screen initializes
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<UsersBloc>().add(FetchUsers(token: authState.token));
      context.read<VideoEdukasiBloc>().add(FetchVideos(token: authState.token, userId: authState.id));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitForm(AuthState state) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVideoId == null || _selectedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih video dan user terlebih dahulu')),
        );
        return;
      }

      if (!widget.isEdit) {
        if (state is Authenticated) {
          context.read<CommentsBloc>().add(
              AddComment(
                  token: state.token,
                  id_user: _selectedUserId!,
                  komentar: _commentController.text,
                  videoId: _selectedVideoId!
              )
          );
        }
      } else {
        if (state is Authenticated) {
          context.read<CommentsBloc>().add(
              UpdateComment(
                  token: state.token,
                  id_user: _selectedUserId!,
                  komentar: _commentController.text,
                  videoId: _selectedVideoId!,
                  id_comment: widget.commentData!.id
              )
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Komentar berhasil diperbarui' : 'Komentar berhasil ditambahkan'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Komentar' : 'Tambah Komentar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video Dropdown
              BlocBuilder<VideoEdukasiBloc, VideoEdukasiState>(
                builder: (context, state) {
                  if (state is VideoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is VideoLoaded) {
                    final videos = state.videos;
                    return DropdownButtonFormField<int>(
                      value: _selectedVideoId,
                      decoration: const InputDecoration(
                        labelText: 'Video',
                        border: OutlineInputBorder(),
                      ),
                      items: videos.map<DropdownMenuItem<int>>((VideoEdukasiModel video) {
                        return DropdownMenuItem<int>(
                          value: video.id,
                          child: Text(video.judul),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVideoId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih video terlebih dahulu';
                        }
                        return null;
                      },
                    );
                  } else if (state is VideoError) {
                    return Text('Error: ${state.message}');
                  } else {
                    return const Text('Tidak ada data video');
                  }
                },
              ),

              const SizedBox(height: 16),

              // User Dropdown
              BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersLoaded) {
                    final users = state.users;
                    return DropdownButtonFormField<int>(
                      value: _selectedUserId,
                      decoration: const InputDecoration(
                        labelText: 'User',
                        border: OutlineInputBorder(),
                      ),
                      items: users.map<DropdownMenuItem<int>>((UserModel user) {
                        return DropdownMenuItem<int>(
                          value: user.id,
                          child: Text('${user.nama} (${user.role})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih user terlebih dahulu';
                        }
                        return null;
                      },
                    );
                  } else if (state is UsersError) {
                    return Text('Error: ${state.message}');
                  } else {
                    return const Text('Tidak ada data user');
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Komentar tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  _submitForm(authState);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(widget.isEdit ? 'Update Komentar' : 'Simpan Komentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}