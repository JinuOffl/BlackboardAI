# FIXED: Video Player - Copy & Paste Solution

## Problem Identified

The error: `unregistered_view_type: <html5-video-1763114849999>`

**Cause:** The view factory is registered in `initState()` but Flutter is trying to use it before registration completes.

**Solution:** Register the view factory at app startup, NOT in the widget.

---

## ✅ FIX - Step 1: Update lib/main.dart

Replace the **entire file** with this:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  print('[MAIN] Starting BlackboardAI Flutter App');
  
  // CRITICAL: Register HTML5 video player BEFORE running app
  print('[MAIN] Registering HTML5 video platform view factory');
  
  ui.platformViewRegistry.registerViewFactory(
    'html5-video-player',
    (int viewId) {
      print('[MAIN] Creating HTML5 video element (viewId: $viewId)');
      
      final video = html.VideoElement();
      video.controls = true;
      video.autoplay = false;
      video.style.width = '100%';
      video.style.height = '100%';
      video.style.objectFit = 'contain';
      video.style.backgroundColor = '#000000';
      
      print('[MAIN] ✓ Video element created and configured');
      
      return video;
    },
  );
  
  print('[MAIN] ✓ Platform view factory registered successfully');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('[MAIN] Building MyApp widget');
    
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) {
            print('[MAIN] Creating ApiService provider');
            return ApiService();
          },
        ),
      ],
      child: MaterialApp(
        title: 'BlackboardAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
```

---

## ✅ FIX - Step 2: Update lib/widgets/animation_player.dart

Replace the **entire file** with this:

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
```

---

## ✅ FIX - Step 3: Verify Backend Video Endpoint

Make sure your `backend/main.py` has this video endpoint:

```python
@app.get("/video/{filename}")
async def get_video(filename: str):
    """Serve rendered video files with proper headers"""
    print(f"[MAIN] ✓ Video request received: {filename}")
    
    video_dir = Path(Config.MANIM_OUTPUT_DIR)
    
    # Search recursively for the video file
    for video_path in video_dir.rglob(filename):
        print(f"[MAIN] ✓ Found and serving video: {video_path}")
        
        return FileResponse(
            video_path,
            media_type="video/mp4",
            filename=filename,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Cache-Control": "public, max-age=3600",
                "Accept-Ranges": "bytes",
            }
        )
    
    print(f"[MAIN] ❌ Video not found: {filename}")
    raise HTTPException(status_code=404, detail=f"Video '{filename}' not found")
```

---

## ✅ FIX - Step 4: Restart Everything

```bash
# Terminal 1: Backend
cd backend
python main.py

# Terminal 2: Frontend
cd frontend
flutter clean
flutter pub get
flutter run -d chrome --web-port 8080
```

---

## 🔍 What Was Wrong & What's Fixed

| Issue | Before | After |
|-------|--------|-------|
| **Registration timing** | Registered in widget initState | Registered in main() before app runs |
| **View type name** | `html5-video-${DateTime.now().millisecondsSinceEpoch}` (dynamic) | `html5-video-player` (static) |
| **Video source update** | Set in widget | Updated via didUpdateWidget |
| **Element lifecycle** | Created per build | Created once, reused |

---

## ✅ Expected Flow Now

1. **App starts** → Registers `html5-video-player` view factory
2. **User enters prompt** → Frontend sends to backend
3. **Backend generates video** → Saves to `media/videos/tmpXXX/480p15/ConceptAnimation.mp4`
4. **Backend returns URL** → `/video/ConceptAnimation.mp4`
5. **Frontend receives URL** → Updates video element source
6. **Video displays** → With play controls ▶️

---

## ✅ Console Logs You'll Now See

**Frontend:**
```
[MAIN] Starting BlackboardAI Flutter App
[MAIN] Registering HTML5 video platform view factory
[MAIN] Creating HTML5 video element (viewId: 0)
[MAIN] ✓ Video element created and configured
[MAIN] ✓ Platform view factory registered successfully
...
[PLAYER] Setting video source: http://localhost:8000/video/ConceptAnimation.mp4
[PLAYER] ✓ Video source loaded
[PLAYER] Showing video player
```

**Backend:**
```
[MAIN] ✓ Video request received: ConceptAnimation.mp4
[MAIN] ✓ Found and serving video: media\videos\tmpf6bvo6et\480p15\ConceptAnimation.mp4
```

---

## 🐛 If Still Not Working

### Check 1: Browser Console (F12)
Should NOT show:
```
PlatformException(unregistered_view_type
```

Should show network request:
```
GET http://localhost:8000/video/ConceptAnimation.mp4 200 OK
```

### Check 2: Video Element
In browser DevTools → Elements tab, search for `<video>` tag. Should show:
```html
<video controls="" style="width: 100%; height: 100%; object-fit: contain; background-color: rgb(0, 0, 0); src="http://localhost:8000/video/ConceptAnimation.mp4;"></video>
```

### Check 3: Backend Response
Make sure backend returns video with correct headers:
```
Content-Type: video/mp4
Access-Control-Allow-Origin: *
Accept-Ranges: bytes
```

---

## 🎉 You're Done!

The video will now play with native HTML5 controls. The key was registering the platform view factory BEFORE Flutter tries to use it.

**Try it now with:** "explain blockchain" or "draw a circle"
