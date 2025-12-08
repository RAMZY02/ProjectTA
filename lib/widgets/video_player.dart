import 'dart:async';

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
  Timer? _controlsTimer;

  double _aspectRatio = 16 / 10;

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

    // Set timer untuk hide controls setelah beberapa detik
    _startControlsTimer();
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
        // Restart timer ketika mulai play
        _restartControlsTimer();
      }
    });
  }

  void _seekToPosition(Duration position) {
    _controller.seekTo(position);
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _restartControlsTimer() {
    if (_isPlaying) {
      _startControlsTimer();
    }
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _restartControlsTimer();
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
    _controlsTimer?.cancel();
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.height;
    final calculatedHeight = screenWidth / _aspectRatio;

    return GestureDetector(
      onTap: _showControlsTemporarily, // Ubah ini
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
                      aspectRatio: 16/9,
                      child: Container(
                        color: Colors.black,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                }
              },
            ),

            // Custom controls overlay - selalu ada di stack, tapi opacity berubah
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showControls ? 1.0 : 0.0,
                child: MouseRegion(
                  onEnter: (_) => _showControlsTemporarily(),
                  child: GestureDetector(
                    onTap: () {}, // Kosongkan agar tidak bertabrakan dengan GestureDetector utama
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
                      child: Stack(
                        children: [
                          // Play/Pause button di tengah
                          if (!_isPlaying || _showControls) // Tampilkan jika tidak playing atau controls visible
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

                          // Progress bar di bawah
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
                                        _restartControlsTimer(); // Restart timer saat seek
                                      },
                                      onChangeEnd: (value) {
                                        if (_isPlaying) {
                                          _restartControlsTimer();
                                        }
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
                ),
              ),
            ),

            // Play button kecil di pojok saat video playing dan controls hidden
            if (_isPlaying && !_showControls)
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _showControlsTemporarily,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}