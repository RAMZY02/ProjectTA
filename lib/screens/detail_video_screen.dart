import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/comments/comments_event.dart';
import 'package:project_ta/bloc/history_video/history_video_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_state.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/comments/comments_state.dart';

class DetailVideoScreen extends StatefulWidget {
  final VideoEdukasiModel video;

  const DetailVideoScreen({
    super.key,
    required this.video,
  });

  @override
  State<DetailVideoScreen> createState() => _DetailVideoScreenState();
}

class _DetailVideoScreenState extends State<DetailVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLiked = false;
  late int _likeCount;
  late int _viewCount;
  final TextEditingController _commentController = TextEditingController();
  bool _showCommentField = false;
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<VideoEdukasiBloc>().add(Init());
    _isLiked = widget.video.isLikedByMe;
    _likeCount = widget.video.likes;
    _viewCount = widget.video.views;
    _initializeVideoPlayer();
    context.read<CommentsBloc>().add(InitComment());
  }

  void _initializeVideoPlayer() {
    if (widget.video.link_video.startsWith('asset://')) {
      final path = widget.video.link_video.replaceFirst('asset://', '');
      _videoPlayerController = VideoPlayerController.asset(path);
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.link_video),
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

    // Simulate view count increment
    _viewCount += 1;
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    // Dapatkan state terbaru dari AuthBloc
    final authState = context.read<AuthBloc>().state;

    if (authState is! Authenticated) {
      // Handle case ketika user tidak terautentikasi
      return;
    }

    context.read<CommentsBloc>().add(AddComment(
      videoId: widget.video.id,
      komentar: _commentController.text,
      token: authState.token,
      id_user: authState.id
    ));

    // Reset dan tutup field komentar
    setState(() {
      _commentController.clear();
      _showCommentField = false;
    });

    // Hilangkan keyboard
    _commentFocusNode.unfocus();
  }

  void _handleOutsideTap() {
    if (_showCommentField) {
      setState(() {
        _showCommentField = false;
        _commentController.clear();
      });
      _commentFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is CommentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
        ),
        child: GestureDetector(
          onTap: _handleOutsideTap,
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            appBar: null,
            body: Stack(
              children: [
                Column(
                  children: [
                    // Video Player
                    SafeArea(
                      bottom: false,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: _chewieController),
                      ),
                    ),

                    // Header with back button and title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 20),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.video.judul,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // body semua content dibawah header judul
                    Expanded(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          if(authState is Authenticated) context.read<HistoryVideoBloc>().add(CreateHistoryVideo(token: authState.token, userId: authState.id, videoId: widget.video.id));
                          return BlocBuilder<CommentsBloc, CommentsState>(
                            builder: (context, commentState) {
                              if(authState is Authenticated && commentState is CommentsInitial){
                                context.read<CommentsBloc>().add(FetchComments(
                                  videoId: widget.video.id,
                                  token: authState.token,
                                  id_user: authState.id
                                ));
                              }
                              return RefreshIndicator(
                                onRefresh: () async {
                                  // Reset state ke initial dan fetch komentar baru
                                  if (authState is Authenticated) {
                                    context.read<CommentsBloc>().add(FetchComments(
                                        videoId: widget.video.id,
                                        token: authState.token,
                                        id_user: authState.id
                                    ));
                                  }
                                },
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(), // Penting untuk RefreshIndicator
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Video Info (sama seperti sebelumnya)
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.person, size: 16),
                                                const SizedBox(width: 4),
                                                Text("Admin"),
                                                const Spacer(),
                                                const Icon(Icons.timer, size: 16),
                                                const SizedBox(width: 4),
                                                Text(widget.video.durasi.toString().substring(0, 7)),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              children: [
                                                // like button video
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isLiked = !_isLiked;
                                                      _likeCount += _isLiked ? 1 : -1;
                                                    });
                                                    final videoState = context.read<VideoEdukasiBloc>().state;
                                                    if(!_isLiked && authState is Authenticated && videoState is VideoLoaded){
                                                      context.read<VideoEdukasiBloc>().add(
                                                        UnlikeVideo(token: authState.token, userId: authState.id, videoId: widget.video.id, videos: videoState.videos),
                                                      );
                                                    }
                                                    else if(authState is Authenticated && videoState is VideoLoaded){
                                                      context.read<VideoEdukasiBloc>().add(
                                                        LikeVideo(token: authState.token, userId: authState.id, videoId: widget.video.id, videos: videoState.videos),
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                                        color: _isLiked ? Colors.blue : null,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$_likeCount',
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.remove_red_eye, size: 20),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '$_viewCount',
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: (){},
                                                  child: const Icon(Icons.share, size: 20),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            const Text(
                                              'Deskripsi Video:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Video pembelajaran ${widget.video.judul} untuk kelas ${widget.video.kelas}. '
                                                  'Disediakan oleh Admin dengan durasi ${widget.video.durasi}.',
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Comments Section (sama seperti sebelumnya)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 16, right: 16),
                                        child: Text(
                                          'Komentar:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // List Komentar
                                      if(commentState is CommentsLoading)
                                        Center(
                                          child: CircularProgressIndicator()
                                        )
                                      else if(commentState is CommentsNotFound)
                                        Text(
                                          "Belum ada komentar",
                                          style: TextStyle(
                                            fontSize: 12,
                                          )
                                        )
                                      else if (commentState is CommentsLoaded)
                                        ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: commentState.comments.length,
                                          itemBuilder: (context, index) {
                                            final comment = commentState.comments[index];
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
                                                    backgroundImage: NetworkImage(comment.user.profpic),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              comment.user.nama,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              "Kelas ${comment.user.kelas}",
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(comment.komentar),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              _formatTime(comment.waktu),
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            // like comment
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (comment.isLikedByMe && authState is Authenticated) {
                                                                  context.read<CommentsBloc>().add(
                                                                    UnlikeComment(comment.id, authState.id, authState.token, commentState.comments, authState.id),
                                                                  );
                                                                } else if(authState is Authenticated) {
                                                                  print("${comment.id}, ${authState.id}, ${authState.token}, ${commentState.comments}, ${authState.id}");
                                                                  context.read<CommentsBloc>().add(
                                                                    LikeComment(comment.id, widget.video.id, authState.id, authState.token, commentState.comments),
                                                                  );
                                                                }
                                                              },
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Icon(
                                                                    comment.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                                                    color: comment.isLikedByMe ? Colors.blue : null,
                                                                    size: 16,
                                                                  ),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    '${comment.likes}',
                                                                    style: const TextStyle(fontSize: 14),
                                                                  ),
                                                                ],
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
                                    ],
                                  ),
                                ),
                              );
                            }
                          );
                        }
                      )
                    ),
                  ],
                ),

                // Floating Comment Button/Field
                Positioned(
                  bottom: 40,
                  right: 24,
                  child: _showCommentField
                      ? GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Tulis komentar...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onSubmitted: (value) => _addComment(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _addComment,
                          ),
                        ],
                      ),
                    ),
                  )
                      : FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.comment, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showCommentField = true;
                      });
                      _commentFocusNode.requestFocus();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}