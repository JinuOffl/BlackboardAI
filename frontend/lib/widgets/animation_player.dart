import 'package:flutter/material.dart';
import '../main.dart'; // Import to access globalVideoElement

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
  @override
  void initState() {
    super.initState();
    print('[PLAYER] AnimationPlayer initState called');
    
    if (widget.videoUrl != null) {
      _updateVideoSource(widget.videoUrl!);
    }
  }

  @override
  void didUpdateWidget(AnimationPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.videoUrl != null && widget.videoUrl != oldWidget.videoUrl) {
      print('[PLAYER] Video URL changed from ${oldWidget.videoUrl} to ${widget.videoUrl}');
      _updateVideoSource(widget.videoUrl!);
    }
  }

  void _updateVideoSource(String url) {
    print('[PLAYER] Updating GLOBAL video element source');
    print('[PLAYER] New URL: $url');
    
    // Update the global video element
    globalVideoElement.src = url;
    globalVideoElement.load();
    
    print('[PLAYER] ✓ Global video element source updated and loaded');
    print('[PLAYER] ✓ Video should start playing now!');
  }

  @override
  Widget build(BuildContext context) {
    print('[PLAYER] Building with videoUrl: ${widget.videoUrl}, isLoading: ${widget.isLoading}');
    
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
      print('[PLAYER] Rendering loading state');
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
      print('[PLAYER] Rendering video player');
      
      return Column(
        children: [
          // Video player using HtmlElementView
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
    print('[PLAYER] Rendering empty state');
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
    // Don't dispose the global element, just pause it
    globalVideoElement.pause();
    super.dispose();
  }
}