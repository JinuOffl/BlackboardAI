import 'package:flutter/material.dart';
import 'dart:html' as html;

class AnimationPlayer extends StatefulWidget {
  final String? videoUrl;
  final bool isLoading;

  const AnimationPlayer({
    super.key,
    this.videoUrl,
    required this.isLoading,
  });

  @override
  State<AnimationPlayer> createState() => _AnimationPlayerState();
}

class _AnimationPlayerState extends State<AnimationPlayer> {
  late html.VideoElement _videoElement;

  @override
  void initState() {
    super.initState();
    print('[PLAYER] AnimationPlayer initState called');
    _initializeVideo();
  }

  void _initializeVideo() {
    print('[PLAYER] Initializing video element');
    
    _videoElement = html.document.querySelector('video') as html.VideoElement?
        ?? html.VideoElement();
    
    _videoElement.controls = true;
    _videoElement.autoplay = false;
    _videoElement.style.width = '100%';
    _videoElement.style.height = '100%';
    _videoElement.style.objectFit = 'contain';
    _videoElement.style.backgroundColor = '#000000';
    
    print('[PLAYER] ✓ Video element initialized');
  }

  @override
  void didUpdateWidget(AnimationPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.videoUrl != null && widget.videoUrl != oldWidget.videoUrl) {
      print('[PLAYER] Video URL updated: ${widget.videoUrl}');
      _updateVideoSource(widget.videoUrl!);
    }
  }

  void _updateVideoSource(String url) {
    print('[PLAYER] Setting video source: $url');
    
    _videoElement.src = url;
    _videoElement.load();
    
    print('[PLAYER] ✓ Video source loaded');
  }

  @override
  Widget build(BuildContext context) {
    print('[PLAYER] Building with videoUrl: ${widget.videoUrl}');
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // LOADING STATE
    if (widget.isLoading) {
      print('[PLAYER] Showing loading state');
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Generating animation...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take 10-30 seconds',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      );
    }

    // VIDEO PLAYING STATE
    if (widget.videoUrl != null) {
      print('[PLAYER] Showing video player');
      
      return Column(
        children: [
          // Video player - use HtmlElementView
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const HtmlElementView(
                  viewType: 'html5-video-player',
                ),
              ),
            ),
          ),
          
          // Success message
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green[300], size: 20),
              const SizedBox(width: 8),
              Text(
                'Animation ready! Press ▶️ to play',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // EMPTY STATE
    print('[PLAYER] Showing empty state');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_circle_outline,
          size: 100,
          color: Colors.white24,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter a prompt below to generate an animation',
          style: TextStyle(color: Colors.white54, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    print('[PLAYER] Disposing AnimationPlayer');
    _videoElement.pause();
    super.dispose();
  }
}