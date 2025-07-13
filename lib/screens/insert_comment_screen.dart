import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/comments/comments_event.dart';
import 'package:project_ta/models/comment_model.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

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

      final commentData = {
        'id_video': _selectedVideoId,
        'id_user': _selectedUserId,
        'comment': _commentController.text,
      };

      if (!widget.isEdit) {
        if (state is Authenticated) {
          print("masuk sini kah");
          context.read<CommentsBloc>().add(AddComment(token: state.token, id_user: _selectedUserId!, komentar: _commentController.text, videoId: _selectedVideoId!));
        }
      } else {
        if (state is Authenticated) {
          context.read<CommentsBloc>().add(UpdateComment(token: state.token, id_user: _selectedUserId!, komentar: _commentController.text, videoId: _selectedVideoId!, id_comment: widget.commentData!.id));
        }
      }

      Navigator.pop(context, commentData);
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
              DropdownButtonFormField<int>(
                value: _selectedVideoId,
                decoration: const InputDecoration(
                  labelText: 'Video',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3, 4, 5, 6]
                    .map<DropdownMenuItem<int>>((video) => DropdownMenuItem<int>(
                  value: video,
                  child: Text(video.toString()),
                ))
                    .toList(),
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
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'User',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2]
                    .map<DropdownMenuItem<int>>((user) => DropdownMenuItem<int>(
                  value: user,
                  child: Text(user.toString()),
                ))
                    .toList(),
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