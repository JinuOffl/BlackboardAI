# BlackboardAI

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python)](https://python.org)
[![Manim](https://img.shields.io/badge/Manim-0.19-FF6C37?logo=python)](https://www.manim.community)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**AI-powered educational animation generator** that transforms natural language prompts into stunning animated visualizations using Manim, LLMs, and Flutter Web.

![BlackboardAI Demo](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)

---

## ✨ Features

- 🎬 **AI-Powered Animation Generation**: Convert text prompts to professional animations
- 🧠 **Auto-Correcting Code**: Automatic error detection and LLM-based correction (3 attempts)
- 🚀 **Zero Manual Intervention**: From prompt to rendered video automatically
- 📹 **Real-time Video Playback**: Native HTML5 video player with controls
- 🔄 **Unique Cache Busting**: Ensures correct video plays for each prompt
- 🎨 **Beautiful Web UI**: Single-page Flutter web application
- 📊 **Extensive Logging**: Debug-friendly console logs throughout
- ⚡ **High Performance**: 15-40 seconds per animation generation

---

## 🏗️ Architecture

```
┌──────────────────────────────────────┐
│      Flutter Web UI (Frontend)        │
│   ┌─────────────────────────────┐   │
│   │ Video Player │ Response │   │   │
│   │ LLM Output   │ Input    │   │   │
│   └─────────────────────────────┘   │
└────────────┬─────────────────────────┘
             │ HTTP API
             ↓
┌──────────────────────────────────────┐
│   FastAPI Backend (Python)            │
│   ┌─────────────────────────────┐   │
│   │ LLM Service (OpenRouter)    │   │
│   │ Code Validator (AST)        │   │
│   │ Manim Service (Subprocess)  │   │
│   └─────────────────────────────┘   │
└────────────┬─────────────────────────┘
             │ Subprocess
             ↓
┌──────────────────────────────────────┐
│    Manim Animation Engine             │
│    (Renders MP4 videos)               │
└──────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.10+** with `pip`
- **Flutter 3.0+** with `dart`
- **Manim Community 0.19.0** (installed via pip)
- **Git** for version control
- **OpenRouter API Key** (from https://openrouter.ai)

### 1️⃣ Clone Repository

```bash
git clone https://github.com/JinuOffl/BlackboardAI.git
cd BlackboardAI
```

### 2️⃣ Backend Setup

#### Create Virtual Environment

```bash
cd backend
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
```

#### Install Dependencies

```bash
pip install -r requirements.txt
```

#### Configure Environment

Create `.env` file in `backend/` directory:

```env
OPENROUTER_API_KEY=your_api_key_here
DEFAULT_MODEL=openai/gpt-4o-mini
MANIM_QUALITY=l
MAX_CORRECTION_ATTEMPTS=3
BACKEND_PORT=8000
```

**Get API Key**:
1. Visit https://openrouter.ai
2. Sign up / Log in
3. Navigate to API Keys section
4. Create a new key
5. Paste into `.env`

#### Verify Manim Installation

```bash
manim --version
# Should show: Manim Community v0.19.0
```

If not installed:
```bash
pip install manim==0.19.0
```

#### Start Backend Server

```bash
python main.py
```

**Expected Output**:
```
================================================================================
BLACKBOARD AI - BACKEND SERVER
================================================================================
[CONFIG] Configuration loaded
[LLM] Module loaded
[MAIN] ✓ CORS configured
[MAIN] Starting server on port 8000...
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 3️⃣ Frontend Setup

#### Open New Terminal

```bash
cd frontend
```

#### Get Dependencies

```bash
flutter pub get
```

#### Run on Web

```bash
flutter run -d chrome --web-port 8080
```

**Expected Output**:
```
Launching lib/main.dart on Chrome in debug mode...
lib/main.dart is being served at http://localhost:8080
```

### 4️⃣ Open Browser

Navigate to: **http://localhost:8080**

---

## 💻 Usage

### Basic Flow

1. **Enter Prompt** (bottom section)
   ```
   "Explain Newton's third law"
   "Draw a rocket"
   "Type 'Hello World'"
   ```

2. **Click "Generate"**
   - Loading state appears (10-30 seconds)
   - LLM generates Manim code
   - Code is validated
   - Animation renders
   - Video displays

3. **Watch Animation** (top section)
   - Click play button
   - Use video controls (fullscreen, seek, etc.)
   - Copy generated code (middle section)

### Example Prompts

**Simple Shapes**:
- "Draw a circle"
- "Create a square and triangle"
- "Show concentric circles"

**Educational Content**:
- "Explain the Pythagorean theorem"
- "Show sine and cosine waves"
- "Demonstrate binary search algorithm"

**Text Animation**:
- "Type my name 'Jinu'"
- "Write 'Hello, World!' with effects"
- "Animate the alphabet"

---

## 📁 Project Structure

```
BlackboardAI/
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── config.py               # Configuration settings
│   ├── llm_service.py          # OpenRouter integration
│   ├── manim_service.py        # Manim execution
│   ├── code_validator.py       # AST validation
│   ├── requirements.txt        # Python dependencies
│   ├── .env                    # Environment variables (create this)
│   └── media/
│       └── videos/             # Generated animations
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   └── widgets/
│   │       ├── animation_player.dart
│   │       ├── llm_response_display.dart
│   │       └── prompt_input.dart
│   ├── pubspec.yaml            # Flutter dependencies
│   └── web/
│       └── index.html
│
├── README.md                    # This file
├── TECHNICAL-DOCUMENTATION.md   # Architecture details
└── LICENSE                      # MIT License
```

---

## 🔧 Technology Stack

### Frontend
| Tech | Version | Purpose |
|------|---------|---------|
| Flutter | 3.0+ | Web framework |
| Dart | 3.0+ | Programming language |
| Material Design 3 | Latest | UI components |
| dart:html | Built-in | HTML5 integration |

### Backend
| Tech | Version | Purpose |
|------|---------|---------|
| FastAPI | 0.109.0 | Web framework |
| Python | 3.10+ | Backend language |
| Uvicorn | 0.27.0 | ASGI server |
| HTTPX | 0.26.0 | Async HTTP client |

### Animation
| Tech | Version | Purpose |
|------|---------|---------|
| Manim | 0.19.0 | Animation engine |
| FFmpeg | (auto) | Video encoding |

### External Services
| Service | Purpose |
|---------|---------|
| OpenRouter | Unified LLM API |
| Claude/GPT/Llama | LLM models |

---

## 📚 API Endpoints

### Generate Animation

**Request**:
```bash
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Draw a circle"}'
```

**Response** (200 OK):
```json
{
  "status": "success",
  "message": "Animation generated successfully",
  "code": "from manim import *\nclass ConceptAnimation(Scene):\n    ...",
  "video_url": "/video/tmpXXXX/480p15/ConceptAnimation.mp4?t=1731776100000",
  "attempts": 1
}
```

### Serve Video

**Request**:
```bash
curl http://localhost:8000/video/tmpXXXX/480p15/ConceptAnimation.mp4?t=1731776100000
```

**Response**: MP4 video file

### Health Check

**Request**:
```bash
curl http://localhost:8000/
```

**Response**:
```json
{
  "message": "BlackboardAI API is running",
  "version": "1.0.0"
}
```

---

## 🐛 Troubleshooting

### Backend Issues

#### Error: "OPENROUTER_API_KEY not set"
**Solution**: Create `.env` file with your API key
```bash
cd backend
echo OPENROUTER_API_KEY=your_key_here > .env
```

#### Error: "manim: command not found"
**Solution**: Install Manim
```bash
pip install manim==0.19.0
```

#### Error: "Port 8000 already in use"
**Solution**: Kill process on port 8000
```bash
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -ti:8000 | xargs kill -9
```

### Frontend Issues

#### Error: "Failed to connect to backend"
**Solution**: 
1. Ensure backend is running on port 8000
2. Check CORS is enabled (it is by default)
3. Verify URL in `lib/services/api_service.dart`

#### Error: "Video doesn't play"
**Solution**:
1. Check browser console (F12) for errors
2. Verify video file exists in `backend/media/videos/`
3. Check Network tab for 404 errors
4. Restart frontend: `flutter clean && flutter pub get`

#### Error: "RenderFlex overflowed"
**Solution**: This is a UI layout warning, doesn't affect functionality. Can be ignored or file an issue.

### Manim Issues

#### Error: "Animation rendering timeout"
**Solution**: The animation is too complex
- Try simpler prompts
- Lower resolution: Change `MANIM_QUALITY` to `l` in config
- Increase timeout in `backend/manim_service.py`

#### Error: "File not found after rendering"
**Solution**: Manim output directory issue
- Verify `media/videos/` folder exists
- Check file permissions
- Restart backend

---

## 📖 Contributing

We welcome contributions! Here's how to contribute:

### 1. Fork Repository
```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR_USERNAME/BlackboardAI.git
cd BlackboardAI
```

### 2. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Make Changes
- Follow code style conventions
- Add comments for complex logic
- Test thoroughly

### 4. Commit Changes
```bash
git add .
git commit -m "Add: description of changes"
git push origin feature/your-feature-name
```

### 5. Create Pull Request
- Go to GitHub repository
- Click "Create Pull Request"
- Describe changes clearly
- Wait for review

### Development Guidelines

- **Code Style**: Follow PEP 8 (Python), Dart conventions
- **Testing**: Test features locally before submitting
- **Documentation**: Update README for new features
- **Commits**: Use clear, descriptive commit messages
- **Issues**: Report bugs with reproduction steps

---

## 🚀 Deployment

### Local Development ✅ (This is what you just did!)

### Docker Deployment (Coming Soon)

```bash
# Build images
docker-compose build

# Run containers
docker-compose up

# Access at http://localhost:8080
```

### Cloud Deployment (Future)

- Vercel (Frontend)
- Railway/Render (Backend)
- S3/Cloud Storage (Videos)

---

## 🔐 Security

### Current Security Measures
- ✅ AST-based code validation (prevents injection)
- ✅ Subprocess isolation
- ✅ CORS properly configured
- ✅ Input validation

### Recommendations
- Use HTTPS in production
- Implement rate limiting
- Add user authentication
- Use environment variables for secrets
- Regular security audits

### Report Security Issues
Please report security vulnerabilities to: jinu.offl@gmail.com

---

## 📊 Performance

### Typical Generation Times
- **LLM Generation**: 2-5 seconds
- **Code Validation**: <100ms
- **Manim Rendering**: 10-30 seconds
- **Total**: 15-40 seconds

### Optimization Tips
- Use simpler prompts for faster results
- Lower quality settings for testing (`MANIM_QUALITY=l`)
- Cache commonly used animations

---

## 🎓 Learning Resources

### Understanding the Code

1. **Start Here**: Read `TECHNICAL-DOCUMENTATION.md`
2. **Architecture**: Review system design diagrams
3. **Backend**: Explore `backend/main.py` and services
4. **Frontend**: Check `frontend/lib/screens/home_screen.dart`

### External Resources
- [Manim Documentation](https://docs.manim.community/)
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)
- [Flutter Web Guide](https://docs.flutter.dev/platform-integration/web)
- [OpenRouter API Docs](https://openrouter.ai/docs)

---

## 🗺️ Roadmap

### Phase 1: MVP ✅ (Current)
- [x] Text-to-animation generation
- [x] Auto-correcting code
- [x] Web UI with video playback
- [x] Error handling
- [x] Logging

### Phase 2: Core Features (Next)
- [ ] User authentication
- [ ] Animation history/library
- [ ] Batch processing
- [ ] Export as GIF/WebM
- [ ] Template library

### Phase 3: Advanced Features (Future)
- [ ] Real-time preview
- [ ] Collaboration
- [ ] Custom styles
- [ ] Mobile apps
- [ ] API for third-party integration

### Phase 4: Production (Later)
- [ ] Docker deployment
- [ ] Database backend
- [ ] Admin dashboard
- [ ] Analytics
- [ ] SLA support

---

## 📞 Support & Community

### Get Help
- 📖 Read the documentation
- 🐛 Check existing issues
- 💬 Create a new discussion
- 📧 Email: jinu.offl@gmail.com

### Connect
- GitHub Issues: Report bugs
- GitHub Discussions: Ask questions
- Contributions: Join development

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Jinu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👥 Authors & Contributors

**Original Author**: Jinu (@JinuOffl)

**Contributors**: (Your name here! 👋)

---

## 🙏 Acknowledgments

- **3Blue1Brown** for creating Manim
- **Manim Community** for maintaining the library
- **OpenRouter** for unified LLM access
- **FastAPI** team for excellent documentation
- **Flutter** team for web support

---

## 💡 Ideas & Suggestions

Have an idea? Found a bug? Want to contribute?

1. Check [Issues](https://github.com/JinuOffl/BlackboardAI/issues)
2. Create a new issue or discussion
3. Submit a pull request

---

## 📊 Stats

![GitHub Stars](https://img.shields.io/github/stars/JinuOffl/BlackboardAI?style=social)
![GitHub Forks](https://img.shields.io/github/forks/JinuOffl/BlackboardAI?style=social)

---

## 🎯 Next Steps

### For Users
1. ✅ Clone repository
2. ✅ Setup backend
3. ✅ Setup frontend
4. ✅ Generate animations
5. 📝 Explore examples
6. 🚀 Build custom prompts

### For Developers
1. ✅ Understand architecture
2. 📖 Read technical documentation
3. 🔍 Explore codebase
4. 🛠️ Implement features
5. 🧪 Test thoroughly
6. 📤 Submit pull requests

---

**Made with ❤️ for educational animation generation**

---

## Quick Links

- 🌐 [GitHub Repository](https://github.com/JinuOffl/BlackboardAI)
- 📚 [Technical Documentation](./TECHNICAL-DOCUMENTATION.md)
- 🎬 [Manim Docs](https://docs.manim.community/)
- 🔌 [OpenRouter API](https://openrouter.ai/)
- 🚀 [FastAPI](https://fastapi.tiangolo.com/)

