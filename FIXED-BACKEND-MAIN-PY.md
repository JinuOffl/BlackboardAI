# FIXED backend/main.py - With Unique Video Paths

Replace your entire `backend/main.py` with this:

```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
import uvicorn
from pathlib import Path
import time  # ADD THIS - for timestamp

from config import Config
from llm_service import LLMService
from manim_service import ManimService
from code_validator import CodeValidator

print("=" * 80)
print("BLACKBOARD AI - BACKEND SERVER")
print("=" * 80)

app = FastAPI(title="BlackboardAI API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

print("[MAIN] ✓ CORS configured: development mode (allow all origins)")

# Initialize services
llm_service = LLMService()
manim_service = ManimService()
validator = CodeValidator()

class PromptRequest(BaseModel):
    prompt: str

class AnimationResponse(BaseModel):
    status: str
    message: str
    code: str = None
    video_url: str = None
    attempts: int = 0

@app.get("/")
async def root():
    print("[MAIN] Root endpoint called")
    return {"message": "BlackboardAI API is running", "version": "1.0.0"}

@app.post("/generate", response_model=AnimationResponse)
async def generate_animation(request: PromptRequest):
    """Main endpoint to generate animation from prompt"""
    print("\n" + "=" * 80)
    print(f"[MAIN] NEW REQUEST: {request.prompt}")
    print("=" * 80)
    
    user_prompt = request.prompt.strip()
    
    if not user_prompt:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty")
    
    error_feedback = None
    attempts = 0
    
    while attempts < Config.MAX_CORRECTION_ATTEMPTS:
        attempts += 1
        print(f"\n[MAIN] === ATTEMPT {attempts}/{Config.MAX_CORRECTION_ATTEMPTS} ===")
        
        try:
            # Step 1: Generate code from LLM
            print("[MAIN] Step 1: Generating code from LLM...")
            code = await llm_service.generate_manim_code(user_prompt, error_feedback)
            
            # Step 2: Validate code
            print("[MAIN] Step 2: Validating code...")
            is_valid, error_message = validator.validate_syntax(code)
            
            if not is_valid:
                print(f"[MAIN] ❌ Validation failed: {error_message}")
                error_feedback = error_message
                continue
            
            # Step 3: Extract class name
            print("[MAIN] Step 3: Extracting scene class name...")
            scene_name = validator.extract_class_name(code)
            if not scene_name:
                scene_name = "ConceptAnimation"
            
            # Step 4: Render animation
            print("[MAIN] Step 4: Rendering animation...")
            video_path = await manim_service.render_animation(code, scene_name)
            
            # Success!
            print("[MAIN] ✓✓✓ SUCCESS! Animation generated")
            print(f"[MAIN] Video: {video_path}")
            print(f"[MAIN] Attempts: {attempts}")
            
            # ✅ FIX: Generate unique path with timestamp
            # Get the relative path from media/videos folder
            video_rel_path = Path(video_path).relative_to(Config.MANIM_OUTPUT_DIR)
            
            # Create unique URL with timestamp to prevent caching
            timestamp = int(time.time() * 1000)
            video_url = f"/video/{video_rel_path.as_posix()}?t={timestamp}"
            
            print(f"[MAIN] ✓ Generated unique video URL: {video_url}")
            
            return AnimationResponse(
                status="success",
                message="Animation generated successfully",
                code=code,
                video_url=video_url,  # ✅ Return unique path with timestamp
                attempts=attempts
            )
            
        except Exception as e:
            error_msg = str(e)
            print(f"[MAIN] ❌ Error in attempt {attempts}: {error_msg}")
            
            if attempts >= Config.MAX_CORRECTION_ATTEMPTS:
                print("[MAIN] Max attempts reached. Giving up.")
                raise HTTPException(
                    status_code=500,
                    detail=f"Failed after {attempts} attempts: {error_msg}"
                )
            
            error_feedback = f"Code execution error: {error_msg}. Please fix and try again."
    
    # Should not reach here
    raise HTTPException(status_code=500, detail="Unexpected error")

@app.get("/video/{file_path:path}")  # ✅ FIXED: Accept path with subfolders
async def get_video(file_path: str):
    """Serve rendered video files with proper headers"""
    print(f"\n[MAIN] ✓ Video request received: {file_path}")
    
    # Remove timestamp query parameter if present
    if "?" in file_path:
        file_path = file_path.split("?")[0]
    
    print(f"[MAIN] Looking for: {file_path}")
    
    # Build full path
    full_path = Path(Config.MANIM_OUTPUT_DIR) / file_path
    
    print(f"[MAIN] Full path: {full_path}")
    print(f"[MAIN] File exists: {full_path.exists()}")
    
    if full_path.exists() and full_path.is_file():
        print(f"[MAIN] ✓ Found and serving video: {full_path}")
        return FileResponse(
            full_path,
            media_type="video/mp4",
            headers={
                "Access-Control-Allow-Origin": "*",
                "Cache-Control": "no-cache, no-store, must-revalidate",  # ✅ Force refresh
                "Pragma": "no-cache",  # ✅ HTTP 1.0 compatibility
                "Expires": "0",  # ✅ Expire immediately
                "Accept-Ranges": "bytes",
            }
        )
    
    print(f"[MAIN] ❌ Video not found: {file_path}")
    raise HTTPException(status_code=404, detail=f"Video '{file_path}' not found")

if __name__ == "__main__":
    print(f"\n[MAIN] Starting server on port {Config.BACKEND_PORT}...")
    print(f"[MAIN] Allowed origins: {Config.ALLOWED_ORIGINS}")
    print("=" * 80)
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=Config.BACKEND_PORT,
        log_level=Config.LOG_LEVEL.lower()
    )
```

---

# UPDATED lib/services/api_service.dart

Replace your entire `lib/services/api_service.dart` with this:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  final String baseUrl = 'http://localhost:8000';
  
  ApiService() {
    print('[API] ApiService initialized with baseUrl: $baseUrl');
  }

  /// Generate animation from user prompt
  Future<AnimationResponse> generateAnimation(String prompt) async {
    print('[API] Sending generate request...');
    print('[API] Prompt: "$prompt"');
    
    final url = Uri.parse('$baseUrl/generate');
    print('[API] URL: $url');
    
    try {
      print('[API] Making POST request...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
        }),
      );
      
      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body length: ${response.body.length} chars');
      
      if (response.statusCode == 200) {
        print('[API] ✓ Success! Parsing response...');
        final data = jsonDecode(response.body);
        final result = AnimationResponse.fromJson(data);
        
        print('[API] Status: ${result.status}');
        print('[API] Message: ${result.message}');
        print('[API] Video URL from backend: ${result.videoUrl}');
        print('[API] Attempts: ${result.attempts}');
        
        return result;
      } else {
        print('[API] ❌ Error response: ${response.body}');
        throw Exception('Failed to generate animation: ${response.body}');
      }
    } catch (e) {
      print('[API] ❌ Exception: $e');
      rethrow;
    }
  }

  /// Build complete video URL
  String getVideoUrl(String videoPath) {
    String fullUrl;
    
    // Video path from backend already includes timestamp
    if (videoPath.startsWith('http')) {
      fullUrl = videoPath;
    } else if (videoPath.startsWith('/')) {
      fullUrl = '$baseUrl$videoPath';
    } else {
      fullUrl = '$baseUrl/video/$videoPath';
    }
    
    print('[API] Full video URL: $fullUrl');
    return fullUrl;
  }
}

/// Animation response model
class AnimationResponse {
  final String status;
  final String message;
  final String? code;
  final String? videoUrl;
  final int attempts;

  AnimationResponse({
    required this.status,
    required this.message,
    this.code,
    this.videoUrl,
    required this.attempts,
  });

  factory AnimationResponse.fromJson(Map<String, dynamic> json) {
    print('[API] Parsing AnimationResponse from JSON');
    return AnimationResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      code: json['code'] as String?,
      videoUrl: json['video_url'] as String?,
      attempts: json['attempts'] as int,
    );
  }
}
```

---

# Key Changes Made

## Backend (main.py):

✅ **Import time module**: `import time` for timestamps

✅ **Unique URL generation**:
```python
video_rel_path = Path(video_path).relative_to(Config.MANIM_OUTPUT_DIR)
timestamp = int(time.time() * 1000)
video_url = f"/video/{video_rel_path.as_posix()}?t={timestamp}"
```
Returns: `/video/tmpxb108cvq/480p15/ConceptAnimation.mp4?t=1731776157123`

✅ **Updated video endpoint**:
```python
@app.get("/video/{file_path:path}")  # Now accepts subdirectories
```

✅ **Stronger cache-busting headers**:
```python
"Cache-Control": "no-cache, no-store, must-revalidate",
"Pragma": "no-cache",
"Expires": "0",
```

## Frontend (api_service.dart):

✅ **Simpler getVideoUrl**: No need to add timestamp (backend already does it)

✅ **Proper logging** of video URLs from backend

---

# 🚀 How It Works Now

1. **Backend generates animation**
2. **Backend returns unique URL**:
   - Old: `/video/ConceptAnimation.mp4`
   - New: `/video/tmpxb108cvq/480p15/ConceptAnimation.mp4?t=1731776157123`
3. **Each video has unique path + timestamp**
4. **Browser can't cache** (timestamp changes each time)
5. **Each prompt shows correct animation** ✅

---

# ✅ Test Steps

1. Restart backend:
   ```bash
   python main.py
   ```

2. Restart frontend:
   ```bash
   flutter run -d chrome --web-port 8080
   ```

3. Generate first animation: **"Explain Newton's law"**
   → Should play Newton animation

4. Generate second animation: **"Type 'I love Rukmini'"**
   → Should play NEW animation (not cached Newton)

5. Generate more animations
   → Each should show correct video ✅

---

## Backend Log Example (After Fix)

```
[MAIN] ✓✓✓ SUCCESS! Animation generated
[MAIN] Video: media\videos\tmpxb108cvq\480p15\ConceptAnimation.mp4
[MAIN] ✓ Generated unique video URL: /video/tmpxb108cvq/480p15/ConceptAnimation.mp4?t=1731776157123
```

---

**Now each animation will display correctly without caching issues!** 🎉
