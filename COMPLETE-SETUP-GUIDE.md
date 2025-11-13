# BlackboardAI - Complete Setup Guide

<img src="https://img.shields.io/badge/Python-3.10+-blue.svg" /> <img src="https://img.shields.io/badge/Flutter-3.0+-02569B.svg" /> <img src="https://img.shields.io/badge/FastAPI-0.109-009688.svg" /> <img src="https://img.shields.io/badge/Manim-0.19-FF6C37.svg" />

**BlackboardAI** is an AI-powered Manim animation generator. Users enter a prompt, and the system automatically generates, validates, and renders educational animations using Manim, with automatic error correction powered by LLMs.

## 🎯 Features

✅ **Single-page Flutter Web UI** with three sections (video player, LLM response, prompt input)
✅ **OpenRouter AI Integration** - works with any LLM model
✅ **Automatic Code Validation** - AST-based Python syntax checking
✅ **Auto-correction Loop** - sends errors back to LLM for fixing (up to 3 attempts)
✅ **Programmatic Manim Execution** - no manual terminal commands needed
✅ **Extensive Logging** - every operation logged to console
✅ **CORS Configured** - Flutter web can communicate with FastAPI backend
✅ **Error Handling** - comprehensive try-catch blocks throughout

## 🏗️ Architecture

```
User Input (Flutter Web)
    ↓
FastAPI Backend
    ↓
1. LLM generates Manim code (OpenRouter)
    ↓
2. Validate code (AST parsing)
    ↓
3. If errors → Send back to LLM for correction
    ↓
4. If valid → Execute Manim programmatically
    ↓
5. Serve video to frontend
```

## 📁 Project Structure

```
blackboard-ai/
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── llm_service.py          # OpenRouter integration
│   ├── manim_service.py        # Manim execution
│   ├── code_validator.py       # AST validation
│   ├── config.py               # Configuration
│   ├── requirements.txt        # Python dependencies
│   └── .env                    # Environment variables
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   └── widgets/
│   │       ├── animation_player.dart
│   │       ├── llm_response_display.dart
│   │       └── prompt_input.dart
│   └── pubspec.yaml
│
└── README.md
```

## 🚀 Installation

### Prerequisites

- Python 3.10+ installed
- Flutter 3.0+ installed
- Manim Community v0.19.0 installed
- OpenRouter API key ([Get one here](https://openrouter.ai/))
- Windows 11 (or macOS/Linux with appropriate adjustments)

### Step 1: Backend Setup

#### 1.1 Create Backend Directory
```bash
mkdir blackboard-ai
cd blackboard-ai
mkdir backend
cd backend
```

#### 1.2 Create Python Virtual Environment
```bash
# Windows
python -m venv venv
venv\\Scripts\\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

#### 1.3 Create requirements.txt
```bash
# Create the file with these contents:
cat > requirements.txt << EOL
fastapi==0.109.0
uvicorn[standard]==0.27.0
python-dotenv==1.0.0
httpx==0.26.0
manim==0.19.0
pydantic==2.5.3
python-multipart==0.0.6
EOL
```

#### 1.4 Install Dependencies
```bash
pip install -r requirements.txt
```

#### 1.5 Create .env File
```bash
# Windows
echo OPENROUTER_API_KEY=your_api_key_here > .env

# macOS/Linux
echo "OPENROUTER_API_KEY=your_api_key_here" > .env
```

**⚠️ IMPORTANT**: Replace `your_api_key_here` with your actual OpenRouter API key!

#### 1.6 Copy Backend Files

Copy all the Python files from `blackboard-backend.md` into the `backend/` directory:
- `config.py`
- `code_validator.py`
- `llm_service.py`
- `manim_service.py`
- `main.py`

### Step 2: Frontend Setup

#### 2.1 Create Flutter Project
```bash
cd ..  # Go back to blackboard-ai directory
flutter create frontend
cd frontend
```

#### 2.2 Update pubspec.yaml

Replace the dependencies section in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1
  video_player: ^2.8.1
  json_annotation: ^4.8.1
  flutter_markdown: ^0.6.18
```

#### 2.3 Get Dependencies
```bash
flutter pub get
```

#### 2.4 Copy Frontend Files

Copy all Dart files from `blackboard-frontend.md` into the `lib/` directory:
- `lib/main.dart`
- `lib/screens/home_screen.dart`
- `lib/services/api_service.dart`
- `lib/widgets/animation_player.dart`
- `lib/widgets/llm_response_display.dart`
- `lib/widgets/prompt_input.dart`

### Step 3: Verify Manim Installation

```bash
# Check Manim version
manim --version

# Should show: Manim Community v0.19.0
```

If not installed:
```bash
pip install manim==0.19.0
```

## ▶️ Running the Application

### Terminal 1: Start Backend Server

```bash
cd backend
python main.py
```

**Expected output:**
```
================================================================================
BLACKBOARD AI - BACKEND SERVER
================================================================================
[CONFIG] Configuration loaded
[VALIDATOR] CodeValidator module loaded
[LLM] LLMService module loaded
[MANIM] Module loaded
[MAIN] ✓ CORS configured
[MAIN] Starting server on port 8000...
[MAIN] Allowed origins: ['http://localhost:3000', 'http://localhost:8080', ...]
================================================================================
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

### Terminal 2: Start Flutter Web App

```bash
cd frontend
flutter run -d chrome --web-port 8080
```

**Expected output:**
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...
...
lib/main.dart is being served at http://localhost:8080
```

### Open in Browser

Navigate to: **http://localhost:8080**

## 🎮 Usage

1. **Enter a Prompt**
   - Example: "Draw a rocket"
   - Example: "Create a circle and square forming Squid Game symbol"
   - Example: "Show the Pythagorean theorem"

2. **Click "Generate"**
   - The system will:
     - Send prompt to LLM
     - Generate Manim code
     - Validate syntax
     - Fix errors if needed (up to 3 attempts)
     - Render animation
     - Display video

3. **View Results**
   - **TOP**: Video player shows the animation
   - **MIDDLE**: LLM response, generated code, and status
   - **BOTTOM**: Input field for next prompt

## 🔍 Monitoring & Logs

Both backend and frontend provide extensive logging:

### Backend Logs
```
[CONFIG] Configuration loaded
[LLM] Generating code for prompt: "Draw a rocket..."
[LLM] Sending API request...
[LLM] Status: 200
[LLM] ✓ Generated 450 chars
[VALIDATOR] Starting validation... (450 chars)
[VALIDATOR] ✓ AST parsing successful
[VALIDATOR] ✓ Found manim import
[VALIDATOR] ✓ Found Scene class: ConceptAnimation
[VALIDATOR] ✓ Found construct() method
[VALIDATOR] ✓✓✓ All checks passed!
[MANIM] Starting render for scene: ConceptAnimation
[MANIM] Executing command: manim -ql /tmp/tmpXXX.py ConceptAnimation
[MANIM] ✓ Video rendered: media/videos/tmpXXX/480p15/ConceptAnimation.mp4
[MAIN] ✓✓✓ SUCCESS! Animation generated
```

### Frontend Logs
```
[MAIN] Starting BlackboardAI Flutter App
[HOME] Prompt submitted: "Draw a rocket"
[HOME] Calling API service...
[API] Sending generate request...
[API] URL: http://localhost:8000/generate
[API] Response status: 200
[API] ✓ Success! Parsing response...
[HOME] ✓ Response received
[HOME] Video URL set: http://localhost:8000/video/ConceptAnimation.mp4
```

## 🐛 Troubleshooting

### Issue 1: "OPENROUTER_API_KEY not set"
**Solution**: Create `.env` file in backend folder with your API key:
```
OPENROUTER_API_KEY=your_actual_key_here
```

### Issue 2: "AttributeError: 'Camera' object has no attribute 'frame'"
**Solution**: This is automatically handled by the validator. The LLM is instructed NOT to use `self.camera.frame`.

### Issue 3: "CORS error" in browser
**Solution**: 
1. Check backend is running on port 8000
2. Check frontend is running on port 8080
3. Verify CORS origins in `config.py` include your frontend URL

### Issue 4: "Manim command not found"
**Solution**: 
```bash
pip install manim==0.19.0
```

### Issue 5: Video doesn't play
**Solution**: 
- The current implementation shows a placeholder
- To enable actual playback, implement HTML5 video using `dart:html` package
- Or download the video file and play locally

## 🎨 Customization

### Change LLM Model

Edit `backend/config.py`:
```python
DEFAULT_MODEL = "anthropic/claude-3.5-sonnet"  # or any other model
```

### Change Video Quality

Edit `backend/config.py`:
```python
MANIM_QUALITY = "h"  # Options: l (low), m (medium), h (high), k (4k)
```

### Change Max Correction Attempts

Edit `backend/config.py`:
```python
MAX_CORRECTION_ATTEMPTS = 5  # Default is 3
```

### Change Backend Port

Edit `backend/config.py`:
```python
BACKEND_PORT = 9000  # Change from 8000
```

Then update `frontend/lib/services/api_service.dart`:
```dart
final String baseUrl = 'http://localhost:9000';
```

## 📊 System Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER WEB UI                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  TOP: Video Player (40%)                            │   │
│  │  - Shows rendered Manim animation                   │   │
│  │  - Loading indicator during generation              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MIDDLE: LLM Response (40%)                         │   │
│  │  - Status messages                                  │   │
│  │  - Generated Python code                            │   │
│  │  - Attempt counter                                  │   │
│  │  - Copy button                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  BOTTOM: Prompt Input (20%)                         │   │
│  │  [ Text Field ] [ Generate Button ]                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓ HTTP POST /generate
┌─────────────────────────────────────────────────────────────┐
│                    FASTAPI BACKEND                          │
│                                                             │
│  1. Receive Prompt                                          │
│  2. Call LLM Service (OpenRouter)                          │
│  3. Generate Manim Code                                     │
│  4. Validate Code (AST Parser)                             │
│  5. If Invalid → Loop back to step 2 with error            │
│  6. If Valid → Execute Manim Programmatically              │
│  7. Find Rendered Video File                               │
│  8. Return Video URL                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Security Notes

- **API Keys**: Never commit `.env` file to git
- **CORS**: Restrict allowed origins in production
- **Rate Limiting**: Consider adding rate limits to API endpoints
- **Input Validation**: Prompts are validated for empty strings
- **Code Execution**: Manim code runs in isolated subprocess

## 🚧 Known Limitations

1. **Video Player**: Current implementation shows placeholder. Needs HTML5 video integration.
2. **File Cleanup**: Temporary files are cleaned but rendered videos persist.
3. **Concurrent Requests**: Not optimized for multiple simultaneous users.
4. **Model Limitations**: LLM may still occasionally generate invalid code.
5. **Animation Length**: Limited to 5-10 seconds by default.

## 🛣️ Future Enhancements

- [ ] Implement proper HTML5 video player
- [ ] Add animation templates/examples
- [ ] Support custom Manim configurations
- [ ] Add user authentication
- [ ] Store animation history
- [ ] Export animations in different formats (GIF, WebM)
- [ ] Add real-time preview during generation
- [ ] Support collaborative editing
- [ ] Add animation library/gallery
- [ ] Mobile app version

## 📚 Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Manim Community Documentation](https://docs.manim.community/)
- [OpenRouter API Docs](https://openrouter.ai/docs)

## 📄 License

This project is provided as-is for educational purposes.

## 👥 Contributing

Feel free to submit issues and enhancement requests!

## 🙏 Acknowledgments

- **3Blue1Brown** for creating Manim
- **Manim Community** for maintaining the library
- **OpenRouter** for unified LLM API access
- **FastAPI** team for the excellent framework
- **Flutter** team for cross-platform development

---

**Built with ❤️ for educational animation generation**
