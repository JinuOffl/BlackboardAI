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
    if (widget.isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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

    if (widget.videoUrl != null) {
      print('[PLAYER] Rendering video from: ${widget.videoUrl}');
      
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: HtmlElementView(
                  viewType: 'html5-video-${DateTime.now().millisecondsSinceEpoch}',
                  onPlatformViewCreated: (int id) {
                    print('[PLAYER] Platform view created with ID: $id');
                    _createVideoElement(widget.videoUrl!);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green[300], size: 20),
              const SizedBox(width: 8),
              Text(
                'Click to play ▶️',
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_circle_outline, size: 100, color: Colors.white24),
        const SizedBox(height: 16),
        Text(
          'Enter a prompt below to generate an animation',
          style: TextStyle(color: Colors.white54, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _createVideoElement(String videoUrl) {
    print('[PLAYER] Creating HTML5 video element');
    print('[PLAYER] Video URL: $videoUrl');
    
    final videoElement = html.VideoElement()
      ..src = videoUrl
      ..controls = true
      ..autoplay = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.backgroundColor = '#000000';

    print('[PLAYER] Video element created and configured');

    // Register view factory
    html.window.console.log('Registering video view factory');
    
    // This registers a simple HTML video element
    // The actual rendering happens through HtmlElementView
  }
}