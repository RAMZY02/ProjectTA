import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _showControls = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  double _aspectRatio = 16 / 10; // Nilai default sebelum video diinisialisasi

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _totalDuration = _controller.value.duration;
        _aspectRatio = _controller.value.aspectRatio;
      });
    });
    _controller.addListener(_updateState);
  }

  void _updateState() {
    if (!mounted) return;

    setState(() {
      _isPlaying = _controller.value.isPlaying;
      _currentPosition = _controller.value.position;
      _totalDuration = _controller.value.duration;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        // Hide controls after 3 seconds of playback
        Future.delayed(const Duration(seconds: 3), () {
          if (_controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }
    });
  }

  void _seekToPosition(Duration position) {
    _controller.seekTo(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return [
      if (hours > 0) twoDigits(hours),
      twoDigits(minutes),
      twoDigits(seconds),
    ].join(':');
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.height;
    final calculatedHeight = screenWidth / _aspectRatio;

    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
        if (_showControls && _isPlaying) {
          Future.delayed(const Duration(seconds: 5), () {
            if (_isPlaying) setState(() => _showControls = false);
          });
        }
      },
      child: SizedBox(
        height: calculatedHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _aspectRatio,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: 16/9, // Default selama loading
                      child: Container(
                        color: Colors.black,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                }
              },
            ),

            // Custom controls overlay
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Stack(  // Ganti Column dengan Stack
                    children: [
                      // Play/Pause button - sekarang di tengah layar
                      Center(
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),

                      // Progress bar dan kontrol lainnya di bagian bawah
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Custom progress bar
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.red,
                                  inactiveTrackColor: Colors.grey[300],
                                  trackHeight: 4.0,
                                  thumbColor: Colors.red,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                  ),
                                  overlayColor: Colors.red.withAlpha(32),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14.0,
                                  ),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: _totalDuration.inSeconds.toDouble(),
                                  value: _currentPosition.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    _seekToPosition(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),

                              // Time indicators
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_currentPosition),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_totalDuration - _currentPosition),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Play button center when not playing
            if (!_isPlaying && !_showControls)
              Positioned.fill( // Gunakan Positioned.fill agar button mengisi seluruh area video
                child: Center( // Gunakan Center untuk memposisikan button di tengah
                  child: IconButton(
                    icon: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
          ],
        ),
      )
    );
  }
}