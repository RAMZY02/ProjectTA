import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DetailVideoScreen extends StatefulWidget {
  final Map<String, dynamic> video;
  final List<Map<String, dynamic>> semuaVideo;

  const DetailVideoScreen({
    super.key,
    required this.video,
    required this.semuaVideo,
  });

  @override
  State<DetailVideoScreen> createState() => _DetailVideoScreenState();
}

class _DetailVideoScreenState extends State<DetailVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLiked = false;
  int _likeCount = 1245;
  int _viewCount = 3567;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    // Komentar dummy untuk contoh
    _comments.addAll([
      {
        'nama': 'Andi Setiawan',
        'kelas': '7A',
        'avatar': 'https://randomuser.me/api/portraits/boy/1.jpg',
        'teks': 'Video ini sangat membantu! Terima kasih Pak Guru',
        'waktu': '2 jam yang lalu',
        'suka': 5,
      },
      {
        'nama': 'Budi Santoso',
        'kelas': '7B',
        'avatar': 'https://randomuser.me/api/portraits/boy/2.jpg',
        'teks': 'Bagian penjelasan di menit 10:30 sangat jelas',
        'waktu': '1 hari yang lalu',
        'suka': 3,
      },
    ]);
  }

  void _initializeVideoPlayer() {
    if (widget.video['url'].startsWith('asset://')) {
      final path = widget.video['url'].replaceFirst('asset://', '');
      _videoPlayerController = VideoPlayerController.asset(path);
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video['url']),
      );
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: Container(
        color: Colors.grey,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    // Simulasi penambahan view count
    _viewCount += 1;
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'nama': 'Saya',
        'kelas': '7C',
        'avatar': 'https://randomuser.me/api/portraits/lego/1.jpg',
        'teks': _commentController.text,
        'waktu': 'Baru saja',
        'suka': 0,
      });
      _commentController.clear();
      _commentFocusNode.unfocus();
    });
  }

  void _likeComment(int index) {
    setState(() {
      _comments[index]['suka'] += 1;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getRekomendasiVideo() {
    return widget.semuaVideo
        .where((v) =>
    v['kelas'] == widget.video['kelas'] &&
        v['judul'] != widget.video['judul'])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final rekomendasiVideo = getRekomendasiVideo();

    return Scaffold(
      // AppBar dihilangkan
      appBar: null,
      body: Column(
        children: [
          // Video Player (Tetap di atas saat scroll)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(controller: _chewieController),
          ),

          // Header dengan tombol back dan judul
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tombol back
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                // Judul video
                Expanded(
                  child: Text(
                    widget.video['judul'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Konten yang bisa di-scroll (komentar dan rekomendasi)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Video
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text(widget.video['guru']),
                            const Spacer(),
                            const Icon(Icons.timer, size: 16),
                            const SizedBox(width: 4),
                            Text(widget.video['durasi']),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                color: _isLiked ? Colors.blue : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLiked = !_isLiked;
                                  _likeCount += _isLiked ? 1 : -1;
                                });
                              },
                            ),
                            Text('$_likeCount'),
                            const SizedBox(width: 16),
                            const Icon(Icons.remove_red_eye, size: 20),
                            const SizedBox(width: 4),
                            Text('$_viewCount'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // Aksi share video
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Deskripsi Video:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video pembelajaran ${widget.video['judul']} untuk ${widget.video['kelas']}. '
                              'Dibawakan oleh ${widget.video['guru']} dengan durasi ${widget.video['durasi']}.',
                        ),
                      ],
                    ),
                  ),

                  // Bagian Komentar
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Komentar:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada komentar'),
                    )
                  else
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(comment['avatar']),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment['nama'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          comment['kelas'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(comment['teks']),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          comment['waktu'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.thumb_up, size: 16),
                                          onPressed: () => _likeComment(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        Text(
                                          '${comment['suka']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Rekomendasi Video
                  if (rekomendasiVideo.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Rekomendasi Video Lainnya:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: rekomendasiVideo.length,
                      itemBuilder: (context, index) {
                        final video = rekomendasiVideo[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(video['thumbnail']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            title: Text(video['judul']),
                            subtitle: Text('${video['durasi']} • ${video['guru']}'),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailVideoScreen(
                                    video: video,
                                    semuaVideo: widget.semuaVideo,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Input Komentar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}