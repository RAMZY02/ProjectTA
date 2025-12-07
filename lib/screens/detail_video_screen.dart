import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/comments/comments_bloc.dart';
import 'package:project_ta/bloc/comments/comments_event.dart';
import 'package:project_ta/bloc/history_video/history_video_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_event.dart';
import 'package:project_ta/bloc/history_video/history_video_state.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_bloc.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_event.dart';
import 'package:project_ta/bloc/video_edukasi/video_edukasi_state.dart';
import 'package:project_ta/models/comment_model.dart';
import 'package:project_ta/models/video_edukasi_model.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../bloc/auth/auth_state.dart';
import '../bloc/comments/comments_state.dart';
import '../bloc/user/user_bloc.dart';

class DetailVideoScreen extends StatefulWidget {
  final VideoEdukasiModel video;

  const DetailVideoScreen({
    super.key,
    required this.video,
  });

  @override
  State<DetailVideoScreen> createState() => _DetailVideoScreenState();
}

class _DetailVideoScreenState extends State<DetailVideoScreen>{
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  late int _likeCount;
  late int _viewCount;
  bool _showCommentField = false;
  final FocusNode _commentFocusNode = FocusNode();

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  Timer? _watchTimer;
  Duration _accumulatedWatchTime = Duration.zero;
  DateTime? _lastStartTime;
  bool _hasRewarded = false;
  bool _isTimerRunning = false;
  bool initSuccess = false;

  final ScrollController _scrollController = ScrollController();
  bool _isVideoSticky = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.isLikedByMe;
    _likeCount = widget.video.likes;
    _viewCount = widget.video.views;

    // Set orientasi berbeda berdasarkan platform
    if (kIsWeb) {
      // Web: tetap portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Mobile: allow landscape untuk fullscreen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    _initializeVideoPlayer();
    _videoPlayerController.addListener(_videoListener);

    if (!kIsWeb) {
      _setupScrollListener();
    }

    context.read<VideoEdukasiBloc>().add(InitVideoEdukasi());
    context.read<CommentsBloc>().add(InitComment());

    final historyVideoState = context.read<HistoryVideoBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if(authState is Authenticated && historyVideoState is HistoryVideoInitial) {
      context.read<HistoryVideoBloc>().add(CreateHistoryVideo(
          token: authState.token,
          userId: authState.id,
          videoId: widget.video.id
      ));
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final scrollPosition = _scrollController.position.pixels;
      final videoHeight = MediaQuery.of(context).size.width * 9 / 16;

      if (scrollPosition > videoHeight && !_isVideoSticky) {
        setState(() {
          _isVideoSticky = true;
        });
      } else if (scrollPosition <= videoHeight && _isVideoSticky) {
        setState(() {
          _isVideoSticky = false;
        });
      }
    });
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.link_video)
    );

    // Konfigurasi berbeda untuk web dan mobile
    if (kIsWeb) {
      _initializeForWeb();
    } else {
      _initializeForMobile();
    }

    _startWatchTimer();
    setState(() {
      _viewCount += 1;
    });
  }

  void _initializeForWeb() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      // Web: tetap portrait saja
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp
      ],
      // Web: gunakan native controls untuk performa lebih baik
      useRootNavigator: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey[300]!,
      ),
      placeholder: Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error memuat video',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _initializeForMobile() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      // Mobile: allow landscape untuk fullscreen
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      // Mobile: tambahkan fitur fullscreen yang lebih baik
      fullScreenByDefault: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey[300]!,
      ),
      placeholder: Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error memuat video',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Listener untuk menangani perubahan orientasi di mobile
    _chewieController.addListener(() {
      if (_chewieController.isFullScreen) {
        // Saat fullscreen di mobile, lock ke landscape
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        // Saat keluar fullscreen, kembali ke portrait
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    });
  }

  void _videoListener() {
    if (_videoPlayerController.value.isPlaying) {
      _startWatchTimer();
    } else {
      _pauseWatchTimer();
    }
  }

  void _startWatchTimer() {
    if (_isTimerRunning) return;

    setState(() {
      _isTimerRunning = true;
      _lastStartTime = DateTime.now();
    });

    _watchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentDuration = DateTime.now().difference(_lastStartTime!);
      final totalDuration = _accumulatedWatchTime + currentDuration;

      if (totalDuration.inSeconds >= 301 && !_hasRewarded) {
        _giveRewardPoints();
        setState(() {
          _hasRewarded = true;
        });
      }
    });
  }

  void _pauseWatchTimer() {
    if (!_isTimerRunning) return;

    _watchTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _accumulatedWatchTime += DateTime.now().difference(_lastStartTime!);
      _lastStartTime = null;
    });
  }

  void _giveRewardPoints() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<UserBloc>().add(UpdatePoin(
        token: authState.token,
        poin: authState.poin + 5,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Anda mendapatkan 5 poin untuk menonton selama 5 menit!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final authState = context.read<AuthBloc>().state;

    if (authState is! Authenticated) {
      return;
    }

    context.read<CommentsBloc>().add(AddComment(
        videoId: widget.video.id,
        komentar: _commentController.text,
        token: authState.token,
        id_user: authState.id
    ));

    setState(() {
      _commentController.clear();
      _showCommentField = false;
    });

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
    _videoPlayerController.removeListener(_videoListener);
    _watchTimer?.cancel();
    _accumulatedWatchTime = Duration.zero;
    _hasRewarded = false;

    // Hapus listener chewie controller untuk mobile
    if (!kIsWeb) {
      _chewieController.removeListener(() {});
    }

    _videoPlayerController.dispose();
    _chewieController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();

    // Reset orientasi ke default saat dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<HistoryVideoBloc>().add(InitialHistoryVideo());
    return BlocListener<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is CommentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.black.withOpacity(0.3),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: _handleOutsideTap,
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: null,
            body: SafeArea(
              child: Stack(
                children: [
                  // Gunakan layout yang sama untuk semua platform dengan ukuran terkontrol
                  _buildMainLayout(),

                  // Floating Comment Button/Field
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: _showCommentField
                        ? Container(
                      width: MediaQuery.of(context).size.width - 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              style: const TextStyle(fontSize: 14),
                              onSubmitted: (value) => _addComment(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                            onPressed: _addComment,
                          ),
                        ],
                      ),
                    )
                        : FloatingActionButton(
                      elevation: 4,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.comment, color: Colors.white, size: 24),
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
            )
          ),
        ),
      ),
    );
  }

  // Layout utama yang diperbaiki
  Widget _buildMainLayout() {
    return Column(
      children: [
        // Video Player dengan ukuran yang terkontrol
        SafeArea(
          bottom: false,
          child: Container(
            // Batasi tinggi maksimum video player
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4, // Maksimal 40% dari tinggi layar
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController),
            ),
          ),
        ),

        // Header dengan back button dan judul
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.video.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Konten utama yang bisa di-scroll
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }

  // Konten yang bisa di-scroll
  Widget _buildScrollableContent() {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
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
                  color: Theme.of(context).primaryColor,
                  onRefresh: () async {
                    if (authState is Authenticated) {
                      context.read<CommentsBloc>().add(FetchComments(
                          videoId: widget.video.id,
                          token: authState.token,
                          id_user: authState.id
                      ));
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Info Section
                        _buildVideoInfoSection(authState),

                        // Comments Section
                        _buildCommentsSection(commentState, authState),

                        // Tambahkan padding di bottom untuk menghindari tabrakan dengan FAB
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  // Widget untuk section info video
  Widget _buildVideoInfoSection(AuthState authState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Creator info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      widget.video.nama_user,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Like and View count
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      count: _likeCount,
                      isActive: _isLiked,
                      onTap: () {
                        setState(() {
                          _isLiked = !_isLiked;
                          _likeCount += _isLiked ? 1 : -1;
                        });
                        final videoState = context.read<VideoEdukasiBloc>().state;
                        if(!_isLiked && authState is Authenticated && videoState is VideoLoaded){
                          context.read<VideoEdukasiBloc>().add(
                            UnlikeVideo(
                                token: authState.token,
                                userId: authState.id,
                                videoId: widget.video.id,
                                videos: videoState.videos
                            ),
                          );
                        }
                        else if(authState is Authenticated && videoState is VideoLoaded){
                          context.read<VideoEdukasiBloc>().add(
                            LikeVideo(
                                token: authState.token,
                                userId: authState.id,
                                videoId: widget.video.id,
                                videos: videoState.videos
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.remove_red_eye,
                      count: _viewCount,
                      isActive: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Deskripsi Video',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.video.deskripsi,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk section komentar
  Widget _buildCommentsSection(CommentsState commentState, AuthState authState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Komentar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              if (commentState is CommentsLoaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${commentState.comments.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if(commentState is CommentsLoading)
            _buildLoadingComments()
          else if(commentState is CommentsNotFound)
            _buildEmptyComments()
          else if (commentState is CommentsLoaded)
              ...commentState.comments.map((comment) =>
                  _buildCommentItem(comment, authState, commentState)
              ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int? count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.blue[700] : Colors.grey[600],
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.blue[700] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, AuthState authState, CommentsLoaded commentState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(comment.user.profpic),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Kelas ${comment.user.kelas}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.komentar,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _formatTime(comment.waktu),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (comment.isLikedByMe && authState is Authenticated) {
                          context.read<CommentsBloc>().add(
                            UnlikeComment(comment.id, authState.id, authState.token, commentState.comments, authState.id),
                          );
                        } else if(authState is Authenticated) {
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
                            size: 14,
                            color: comment.isLikedByMe ? Colors.blue[700] : Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${comment.likes}',
                            style: TextStyle(
                              fontSize: 10,
                              color: comment.isLikedByMe ? Colors.blue[700] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
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
  }

  Widget _buildLoadingComments() {
    return Column(
      children: List.generate(2, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 150,
                    height: 10,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildEmptyComments() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.comment, size: 36, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                "Belum ada komentar",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Jadilah yang pertama berkomentar!",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        )
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} mnt lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}