import 'package:flutter/material.dart';

class InsertCommentScreen extends StatefulWidget {
  final Map<String, dynamic>? commentData;
  final List<Map<String, dynamic>> videos;
  final List<Map<String, dynamic>> users;

  bool get isEdit => commentData != null;

  const InsertCommentScreen({
    super.key,
    this.commentData,
    this.videos = const [],
    this.users = const [],
  });

  @override
  State<InsertCommentScreen> createState() => _InsertCommentScreenState();
}

class _InsertCommentScreenState extends State<InsertCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  late int? _selectedVideoId;
  late int? _selectedUserId;
  late TextEditingController _commentController;
  late TextEditingController _likesController;

  @override
  void initState() {
    super.initState();
    _selectedVideoId = widget.commentData?['id_video'];
    _selectedUserId = widget.commentData?['id_user'];
    _commentController = TextEditingController(text: widget.commentData?['comment'] ?? '');
    _likesController = TextEditingController(text: widget.commentData?['likes']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _commentController.dispose();
    _likesController.dispose();
    super.dispose();
  }

  void _submitForm() {
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
        'likes': int.parse(_likesController.text),
        'user_name': widget.users.firstWhere(
                (u) => u['id'] == _selectedUserId,
            orElse: () => {'name': 'Unknown'})['name'],
      };

      Navigator.pop(context, commentData);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                items: widget.videos
                    .map<DropdownMenuItem<int>>((video) => DropdownMenuItem<int>(
                  value: video['id'] as int,
                  child: Text(video['title']),
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
                items: widget.users
                    .map<DropdownMenuItem<int>>((user) => DropdownMenuItem<int>(
                  value: user['id'] as int,
                  child: Text(user['name']),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _likesController,
                decoration: const InputDecoration(
                  labelText: 'Likes',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah likes tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
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