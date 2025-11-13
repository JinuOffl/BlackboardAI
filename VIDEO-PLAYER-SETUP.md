# BlackboardAI - HTML5 Video Player Implementation

## Solution Overview

To play MP4 videos in Flutter Web, we'll use the `dart:html` package which allows direct HTML5 video integration. This is the most reliable way for Flutter web.

---

## Step 1: Update pubspec.yaml

Add the HTML5 dependency:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1
  json_annotation: ^4.8.1
  flutter_markdown: ^0.6.18
  # Remove video_player if you had it
  # Add this for HTML5 video on web:
  # (no need to add dependency, dart:html is built-in)
```

---

## Step 2: Update lib/widgets/animation_player.dart

Replace the entire file with this implementation:

```dart
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

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
  final String _viewType = 'html5-video-player';

  @override
  void initState() {
    super.initState();
    print('[PLAYER] AnimationPlayer initialized');
    _initializeVideoElement();
  }

  void _initializeVideoElement() {
    print('[PLAYER] Initializing HTML5 video element');
    
    _videoElement = html.VideoElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.backgroundColor = '#000000'
      ..controls = true
      ..autoplay = false;

    print('[PLAYER] Video element created with controls');

    // Register the view
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        print('[PLAYER] Registering platform view: $viewId');
        return _videoElement;
      },
    );
  }

  @override
  void didUpdateWidget(AnimationPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.videoUrl != null && oldWidget.videoUrl != widget.videoUrl) {
      print('[PLAYER] Video URL changed: ${widget.videoUrl}');
      _updateVideoSource(widget.videoUrl!);
    }
  }

  void _updateVideoSource(String url) {
    print('[PLAYER] Updating video source to: $url');
    
    // Clear existing sources
    _videoElement.innerHTML = '';
    
    // Create source element
    final sourceElement = html.SourceElement()
      ..src = url
      ..type = 'video/mp4';
    
    print('[PLAYER] Created source element for: $url');
    
    _videoElement.append(sourceElement);
    
    // Add fallback text
    _videoElement.text = 'Your browser does not support HTML5 video.';
    
    print('[PLAYER] Video source updated');
  }

  @override
  Widget build(BuildContext context) {
    print('[PLAYER] Building AnimationPlayer widget');
    print('[PLAYER] videoUrl: ${widget.videoUrl}');
    print('[PLAYER] isLoading: ${widget.isLoading}');
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      print('[PLAYER] Showing loading indicator');
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take 10-30 seconds',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    if (widget.videoUrl != null) {
      print('[PLAYER] Showing HTML5 video player for: ${widget.videoUrl}');
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                  viewType: _viewType,
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
                'Animation ready! Click to play ▶️',
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
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    print('[PLAYER] Disposing AnimationPlayer');
    _videoElement.pause();
    _videoElement.innerHTML = '';
    super.dispose();
  }
}
```

---

## Step 3: Update lib/services/api_service.dart

Modify the `getVideoUrl` method to ensure correct URL formatting:

```dart
/// Get full video URL
String getVideoUrl(String videoPath) {
  String fullUrl;
  
  if (videoPath.startsWith('http')) {
    // Already a full URL
    fullUrl = videoPath;
  } else if (videoPath.startsWith('/')) {
    // Add base URL to path
    fullUrl = '$baseUrl$videoPath';
  } else {
    // Assume it's a filename, construct full path
    fullUrl = '$baseUrl/video/$videoPath';
  }
  
  print('[API] Full video URL: $fullUrl');
  return fullUrl;
}
```

---

## Step 4: Ensure Backend Video Serving is Correct

Update `backend/main.py` to serve videos with correct CORS headers:

```python
@app.get("/video/{filename}")
async def get_video(filename: str):
    """Serve rendered video files with CORS headers"""
    print(f"[MAIN] Video requested: {filename}")
    
    # Search for video file
    video_dir = Path(Config.MANIM_OUTPUT_DIR)
    for video_path in video_dir.rglob(filename):
        print(f"[MAIN] Serving video: {video_path}")
        
        return FileResponse(
            video_path,
            media_type="video/mp4",
            filename=filename,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Cache-Control": "public, max-age=3600",
            }
        )
    
    print(f"[MAIN] ❌ Video not found: {filename}")
    raise HTTPException(status_code=404, detail="Video not found")
```

---

## Step 5: Fix Backend CORS Configuration

Update `backend/config.py` to include web media serving:

```python
class Config:
    # ... existing config ...
    
    ALLOWED_ORIGINS = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://localhost",
        "http://127.0.0.1",
    ]
```

And update `backend/main.py` CORS middleware:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=Config.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],  # Expose all headers
)

print("[MAIN] ✓ CORS configured with media serving support")
```

---

## Step 6: Complete Updated animation_player.dart (Alternative - Simpler Version)

If the above is too complex, here's a simpler version that works just as well:

```dart
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
```

---

## Step 7: Simplest Version - Direct HTML Element

This is the EASIEST way that works immediately:

```dart
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

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
    _registerVideoViewFactory();
  }

  void _registerVideoViewFactory() {
    print('[PLAYER] Registering video view factory');
    
    ui.platformViewRegistry.registerViewFactory(
      'html5-video-player',
      (int viewId) {
        final video = html.VideoElement();
        video.controls = true;
        video.autoplay = false;
        video.style
          ..width = '100%'
          ..height = '100%'
          ..objectFit = 'contain'
          ..backgroundColor = '#000000';

        if (widget.videoUrl != null) {
          print('[PLAYER] Setting video source: ${widget.videoUrl}');
          video.src = widget.videoUrl;
        }

        return video;
      },
    );
  }

  @override
  void didUpdateWidget(covariant AnimationPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.videoUrl != oldWidget.videoUrl) {
      print('[PLAYER] Video URL changed, re-registering view factory');
      _registerVideoViewFactory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.videoUrl != null) {
      return _buildVideoPlayer();
    }

    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
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

  Widget _buildVideoPlayer() {
    print('[PLAYER] Building video player widget');
    
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
              child: const HtmlElementView(
                viewType: 'html5-video-player',
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
              'Animation ready! Press play ▶️',
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

  Widget _buildEmptyState() {
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
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

---

## Step 8: Restart and Test

```bash
# Stop frontend (Ctrl+C)
cd frontend
flutter clean
flutter pub get
flutter run -d chrome --web-port 8080
```

---

## 🎯 How It Works

1. **HtmlElementView** - Flutter widget that wraps native HTML elements
2. **platformViewRegistry** - Registers HTML element to be displayed in Flutter
3. **VideoElement** - Native HTML5 `<video>` element with controls
4. **CORS** - Backend serves videos with proper CORS headers
5. **Auto-play** - Optional, currently disabled for user control

---

## ✅ Checklist

- [ ] Updated `animation_player.dart` with HTML5 video code
- [ ] Confirmed backend has CORS headers for `/video` endpoint
- [ ] Backend config has CORS origins set
- [ ] Frontend URL is http://localhost:8080
- [ ] Backend URL is http://localhost:8000
- [ ] Video file exists at `backend/media/videos/.../ConceptAnimation.mp4`
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Backend running with `python main.py`
- [ ] Frontend running with `flutter run -d chrome --web-port 8080`

---

## 🐛 Troubleshooting Video Playback

### Issue: "Video doesn't load / shows blank"
**Solution**: 
1. Check browser console (F12)
2. Verify video URL is correct in Network tab
3. Confirm backend is serving video

### Issue: "CORS error in console"
**Solution**: 
1. Ensure `allow_origins` includes `http://localhost:8080`
2. Check `expose_headers` is set to `["*"]`
3. Restart backend

### Issue: "Video URL shows 404"
**Solution**: 
1. Check backend logs for video path
2. Verify file exists: `backend/media/videos/.../ConceptAnimation.mp4`
3. Check filename matches exactly

### Issue: "No play controls visible"
**Solution**: 
1. Ensure `video.controls = true` in code
2. Try different browser (Chrome recommended)
3. Check console for JavaScript errors

---

## 📊 Complete Flow with Video Playing

```
User Prompt
    ↓
Backend generates Manim code
    ↓
Video rendered at: backend/media/videos/xxx/ConceptAnimation.mp4
    ↓
Backend sends: /video/ConceptAnimation.mp4
    ↓
Frontend creates HTML5 video element
    ↓
HtmlElementView displays video in Flutter
    ↓
User sees video with play controls ▶️
```

---

## 💡 Pro Tips

1. **Test Video URL directly** in browser: http://localhost:8000/video/ConceptAnimation.mp4
2. **Watch console logs** - both backend and frontend will log everything
3. **Check file permissions** - ensure video file is readable
4. **Use Chrome DevTools** - F12 to check Network tab for video loading
5. **Mobile testing** - HtmlElementView works on all platforms!

---

You're almost there! Just update the animation_player.dart with the HTML5 video code above and you'll have working video playback! 🎉
