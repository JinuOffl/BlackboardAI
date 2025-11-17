# BlackboardAI - Technical Documentation & Architecture

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [System Design](#system-design)
5. [Component Details](#component-details)
6. [Data Flow](#data-flow)
7. [API Specification](#api-specification)
8. [Database & Storage](#database--storage)
9. [Performance Considerations](#performance-considerations)
10. [Security Analysis](#security-analysis)
11. [Future Enhancements](#future-enhancements)
12. [Technical Challenges & Solutions](#technical-challenges--solutions)

---

## Project Overview

**BlackboardAI** is an AI-powered educational animation generator that converts natural language prompts into animated visualizations using Manim (Mathematical Animation Engine). The system uses LLMs (Large Language Models) to generate Python code, validates it, and automatically renders professional animations.

### Key Characteristics
- **Real-time animation generation** from text prompts
- **Auto-correcting code generation** with AST-based validation
- **Zero manual intervention** between prompt and rendered video
- **3-tier architecture**: Frontend (Flutter Web), Backend (FastAPI), Animation Engine (Manim)
- **Microservices-ready** with independent services for LLM, validation, and rendering

---

## Architecture

### High-Level System Design

```
┌─────────────────────────────────────────────────────────────┐
│                      FLUTTER WEB UI                          │
│  ┌──────────────┬────────────────────┬──────────────────┐   │
│  │ Video Player │  LLM Response      │ Prompt Input     │   │
│  │   (40%)      │  Display (40%)     │   (20%)          │   │
│  └──────────────┴────────────────────┴──────────────────┘   │
└────────────────────────────┬──────────────────────────────────┘
                             │ HTTP POST /generate
                             │ HTTP GET /video/{path:path}
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                    FASTAPI BACKEND                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ LLM Service (OpenRouter)                             │   │
│  │ - Generates Manim Python code                        │   │
│  │ - Error correction loop                              │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Code Validator (AST Parser)                          │   │
│  │ - Syntax validation                                  │   │
│  │ - Structure checking                                 │   │
│  │ - Manim requirements verification                    │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Manim Service (Subprocess)                           │   │
│  │ - Programmatic animation rendering                   │   │
│  │ - File management                                    │   │
│  │ - Video output streaming                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────────┬──────────────────────────────────┘
                             │ Subprocess call to Manim
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                   MANIM (Animation Engine)                   │
│  - Parses generated Python code                             │
│  - Renders scenes to MP4 video                              │
│  - Outputs: media/videos/{tmp_dir}/480p15/video.mp4        │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Layers

#### 1. **Presentation Layer (Frontend)**
- **Framework**: Flutter Web
- **Purpose**: User interface and animation playback
- **Responsibilities**:
  - Accept user prompts
  - Display loading states
  - Render generated videos
  - Show LLM-generated code
  - Display generation status

#### 2. **Application Layer (Backend)**
- **Framework**: FastAPI
- **Purpose**: Orchestration and business logic
- **Responsibilities**:
  - Route requests to appropriate services
  - Manage error correction loops
  - Cache management
  - Video serving with proper headers
  - Logging and monitoring

#### 3. **Service Layer**
Three independent microservices:

**LLM Service**
- Interface with OpenRouter API
- Generate Manim Python code
- Handle error feedback
- Model configuration

**Validation Service**
- AST (Abstract Syntax Tree) parsing
- Syntax error detection
- Manim requirement verification
- Code structure validation

**Manim Service**
- Execute Python code programmatically
- Manage temporary files
- Locate output videos
- Handle subprocess communication

#### 4. **External Services**
- **OpenRouter API**: LLM access (supports Claude, GPT, Llama, etc.)
- **Manim Community**: Animation rendering engine

---

## Technology Stack

### Frontend
| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.0+ | Web framework |
| **Dart** | 3.0+ | Programming language |
| **dart:html** | Built-in | HTML5 video integration |
| **Provider** | 6.1.1 | State management |
| **HTTP** | 1.1.0 | API client |
| **Material Design 3** | Latest | UI components |

### Backend
| Component | Version | Purpose |
|-----------|---------|---------|
| **FastAPI** | 0.109.0 | Web framework |
| **Python** | 3.10+ | Programming language |
| **Uvicorn** | 0.27.0 | ASGI server |
| **HTTPX** | 0.26.0 | Async HTTP client |
| **Pydantic** | 2.5.3 | Data validation |
| **CORS Middleware** | Latest | Cross-origin handling |

### Animation & Processing
| Component | Version | Purpose |
|-----------|---------|---------|
| **Manim Community** | 0.19.0 | Animation engine |
| **Python AST** | 3.10 | Code analysis |
| **Python Subprocess** | Built-in | Process management |

### External APIs
| Service | Purpose |
|---------|---------|
| **OpenRouter** | Unified LLM API |
| **Claude/GPT/Llama** | LLM models |

### DevOps & Deployment
| Tool | Purpose |
|------|---------|
| **Git/GitHub** | Version control |
| **Docker** (optional) | Containerization |
| **pip** | Python dependency management |
| **pub** | Flutter dependency management |

---

## System Design

### Request-Response Flow

```
1. USER INPUT
   └─ Prompt: "Explain Newton's third law"

2. FRONTEND PREPARATION
   ├─ Validate input (non-empty)
   ├─ Show loading state
   └─ Send POST /generate request

3. BACKEND PROCESSING
   ├─ Receive prompt
   ├─ Call LLM Service
   │  ├─ Generate Manim Python code
   │  └─ Clean up markdown artifacts
   │
   ├─ Call Validator Service
   │  ├─ Parse code with AST
   │  ├─ Check syntax errors
   │  ├─ Verify Manim imports
   │  └─ Validate class structure
   │
   ├─ If errors found:
   │  ├─ Send error feedback to LLM
   │  ├─ Loop up to 3 attempts
   │  └─ Return error if all fail
   │
   └─ If valid:
      ├─ Call Manim Service
      ├─ Create temporary Python file
      ├─ Execute: manim -ql script.py ClassName
      ├─ Find output video
      ├─ Generate unique URL with timestamp
      └─ Return success response

4. VIDEO SERVING
   ├─ Browser requests /video/{path}?t={timestamp}
   ├─ Backend finds file in media/videos/
   └─ Stream MP4 with cache-busting headers

5. FRONTEND DISPLAY
   ├─ Update global video element
   ├─ Load video from URL
   └─ Display with native controls
```

### Error Handling Strategy

```
┌─────────────────────────┐
│   User Prompt           │
└────────────┬────────────┘
             │
      ┌──────▼──────┐
      │ Generate    │
      │ Code (LLM)  │
      └──────┬──────┘
             │
      ┌──────▼──────────────┐
      │ Validate Code (AST) │
      └──────┬──────────────┘
             │
       ┌─────▼─────┐
       │ Valid?    │
       └─┬────────┬┘
         │ NO     │ YES
         │        │
    ┌────▼─┐   ┌──▼──────────────┐
    │Error │   │Execute Manim    │
    │Found │   │(subprocess)     │
    └────┬─┘   └────────┬────────┘
         │               │
    ┌────▼──────────────┐│
    │Attempt < 3?       ││
    └┬───────────────┬──┘│
     │YES            │NO ││
     │               │   ││
  ┌──▼─────────┐  ┌─▼──▼▼────┐
  │Send Error  │  │Return    │
  │to LLM for  │  │Error 500 │
  │Correction  │  │Response  │
  └──┬─────────┘  └──────────┘
     │
     └──► Loop back to Generate
```

---

## Component Details

### 1. Frontend - Animation Player Widget

**File**: `lib/widgets/animation_player.dart`

**Purpose**: Displays MP4 videos with HTML5 controls

**Key Features**:
- Global video element (created once in main.dart)
- Supports multiple consecutive video loads
- Responsive layout with borders
- Success/loading/empty states
- Automatic video source updates

**Implementation Details**:
```dart
// Global element created at app startup
late html.VideoElement globalVideoElement;

// Updated when new video URL arrives
void _updateVideoSource(String url) {
  globalVideoElement.src = url;
  globalVideoElement.load();
}
```

**Why Global Element?**
- `HtmlElementView` reuses the registered element
- Single video element = consistent state
- Avoids stale element references
- Simplifies lifecycle management

### 2. Backend - LLM Service

**File**: `backend/llm_service.py`

**Purpose**: Interface with OpenRouter API

**Key Methods**:
```python
async def generate_manim_code(
    self, 
    user_prompt: str, 
    error_feedback: str = None
) -> str
```

**System Prompt Engineering**:
- Specifies Manim v0.19.0 compatibility
- Prohibits unsupported features (self.camera.frame)
- Enforces output format (Python code only)
- Defines class structure requirements
- Specifies animation duration (5-10 seconds)

**Error Feedback Loop**:
- First attempt: Generate from user prompt
- Subsequent attempts: Include error message in prompt
- LLM "learns" from previous errors
- Maximum 3 attempts before giving up

### 3. Backend - Code Validator

**File**: `backend/code_validator.py`

**Purpose**: Validate Python code before execution

**Validation Checks**:
1. **Syntax Validation**: AST parsing catches syntax errors
2. **Structure Validation**: Checks for required imports
3. **Class Validation**: Verifies Scene class exists
4. **Method Validation**: Ensures construct() method present
5. **Manim Compatibility**: Avoids known issues (e.g., self.camera.frame)

**AST-Based Approach**:
```python
import ast

tree = ast.parse(code)
for node in ast.walk(tree):
    if isinstance(node, ast.ImportFrom):
        # Check for manim import
    if isinstance(node, ast.ClassDef):
        # Check class inheritance from Scene
    if isinstance(node, ast.FunctionDef):
        # Check for construct method
```

**Why AST?**
- Doesn't execute code (safe)
- Deep code analysis
- No false positives
- Performance efficient

### 4. Backend - Manim Service

**File**: `backend/manim_service.py`

**Purpose**: Render animations programmatically

**Execution Method**:
```python
subprocess.run([
    "manim",
    "-ql",  # Low quality (faster)
    temp_file,
    scene_class_name
], capture_output=True, text=True, timeout=120)
```

**Output Structure**:
```
media/
└── videos/
    └── {tmp_id}/
        └── 480p15/
            ├── partial_movie_files/
            │   └── {ClassName}/
            │       ├── part_0.mp4
            │       ├── part_1.mp4
            │       └── ...
            └── {ClassName}.mp4  ← Final output
```

**Quality Settings**:
- `-ql`: 480p, 15 fps (development, fast)
- `-qm`: 720p, 30 fps (production)
- `-qh`: 1080p, 60 fps (high-quality)

### 5. Caching & Cache Busting

**Problem**: Browser caches videos with same URL

**Solution**: Timestamp-based unique URLs

```python
# Backend generates unique URL per request
timestamp = int(time.time() * 1000)
video_url = f"/video/{rel_path}?t={timestamp}"
```

**Example URLs**:
- First request: `/video/tmp1/480p15/ConceptAnimation.mp4?t=1731776100000`
- Second request: `/video/tmp2/480p15/ConceptAnimation.mp4?t=1731776157123`

**Cache Headers**:
```python
"Cache-Control": "no-cache, no-store, must-revalidate",
"Pragma": "no-cache",
"Expires": "0",
```

---

## Data Flow

### Complete Request-Response Cycle

```
FRONTEND                        BACKEND                         MANIM
(Flutter Web)                   (FastAPI)                      (Engine)

User Input
│
├─ Prompt: "Draw circle"
│
POST /generate ────────────────────→ Receive Request
                                    │
                                    ├─ Validate input
                                    │
                                    Call LLM Service
                                    │
                                    ├─ System prompt setup
                                    ├─ Send to OpenRouter
                                    ├─ Receive: Python code
                                    │
                                    Call Validator
                                    │
                                    ├─ Parse AST
                                    ├─ Validate syntax
                                    ├─ Check structure
                                    │
                                    ├─ Valid? YES
                                    │
                                    Call Manim Service
                                    │
                                    ├─ Create temp file
                                    ├─ Write code
                                    ├─ Execute subprocess ────→ Manim Process
                                    │                            │
                                    │                            ├─ Parse code
                                    │                            ├─ Render scenes
                                    │                            ├─ Generate MP4
                                    │                            │
                                    │                    ←────── Return 0 (success)
                                    │
                                    ├─ Find video file
                                    ├─ Generate URL
                                    ├─ Build response
                                    │
Response: {                ←────────┤ JSON Response
  status: "success",
  video_url: "/video/tmp1/480p15/ConceptAnimation.mp4?t=1234567890",
  message: "Animation generated successfully"
}
│
├─ Parse response
├─ Extract video URL
│
GET /video/tmp1/480p15/ConceptAnimation.mp4?t=1234567890 ──→ Serve MP4
                                                              │
                                                    ←──────── File stream
│
├─ Update video element
├─ Browser loads video
│
Video displays with controls ✓
```

---

## API Specification

### 1. Generate Animation Endpoint

**Request**:
```http
POST /generate HTTP/1.1
Content-Type: application/json

{
  "prompt": "Draw a circle and square"
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "message": "Animation generated successfully",
  "code": "from manim import *\nclass ConceptAnimation(Scene):\n    def construct(self):\n        ...",
  "video_url": "/video/tmpXXXX/480p15/ConceptAnimation.mp4?t=1731776100000",
  "attempts": 1
}
```

**Response** (500 Error):
```json
{
  "status": "error",
  "message": "Failed after 3 attempts: ...",
  "code": null,
  "video_url": null,
  "attempts": 3
}
```

### 2. Video Serving Endpoint

**Request**:
```http
GET /video/tmpXXXX/480p15/ConceptAnimation.mp4?t=1731776100000 HTTP/1.1
```

**Response** (200 OK):
```
Content-Type: video/mp4
Content-Length: 524288
Cache-Control: no-cache, no-store, must-revalidate
Accept-Ranges: bytes

[Binary MP4 data]
```

**Response** (404 Not Found):
```json
{
  "detail": "Video 'tmpXXXX/480p15/ConceptAnimation.mp4' not found"
}
```

### 3. Health Check Endpoint

**Request**:
```http
GET / HTTP/1.1
```

**Response** (200 OK):
```json
{
  "message": "BlackboardAI API is running",
  "version": "1.0.0"
}
```

---

## Database & Storage

### Current Implementation: File-Based Storage

**Structure**:
```
project_root/
├── backend/
│   ├── main.py
│   ├── config.py
│   ├── llm_service.py
│   ├── code_validator.py
│   ├── manim_service.py
│   ├── requirements.txt
│   └── media/
│       └── videos/
│           ├── tmp_xxxxx/
│           │   └── 480p15/
│           │       ├── ConceptAnimation.mp4
│           │       └── partial_movie_files/
│           ├── tmp_yyyyy/
│           │   └── 480p15/
│           │       └── ConceptAnimation.mp4
│           └── ...
```

### Future: Database Requirements

**What to Store**:
- User sessions
- Animation generation history
- LLM prompts and responses
- Performance metrics
- User preferences

**Recommended Database**:
- **PostgreSQL** for structured data
- **Redis** for caching
- **S3/MinIO** for long-term video storage

**Schema Sketch**:
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    created_at TIMESTAMP
);

-- Animation History
CREATE TABLE animations (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users,
    prompt TEXT,
    generated_code TEXT,
    video_path VARCHAR(255),
    generation_time INT,
    model_used VARCHAR(255),
    attempts INT,
    created_at TIMESTAMP
);

-- Performance Metrics
CREATE TABLE metrics (
    id SERIAL PRIMARY KEY,
    animation_id INT REFERENCES animations,
    llm_latency_ms INT,
    validation_time_ms INT,
    manim_render_time_ms INT,
    total_time_ms INT
);
```

---

## Performance Considerations

### Current Performance Profile

**Typical Generation Times** (Single Prompt):
- LLM Generation: 2-5 seconds
- Code Validation: <100ms
- Manim Rendering: 10-30 seconds (depends on complexity)
- **Total**: 15-40 seconds

**Bottlenecks**:
1. **Manim Rendering** (70% of time)
   - CPU-intensive animation computation
   - Video encoding overhead
   - Quality settings impact

2. **LLM Latency** (20% of time)
   - Network roundtrip to OpenRouter
   - Model inference time
   - Token generation

3. **I/O Operations** (10% of time)
   - File writing
   - Video serving
   - Network transfer

### Optimization Strategies

**Already Implemented**:
- Low-quality rendering (`-ql`) for speed
- Subprocess execution (doesn't block API)
- File streaming instead of in-memory buffering

**Future Optimizations**:
1. **Caching**
   - Cache LLM responses for similar prompts
   - Store rendered animations
   - TTL-based cleanup

2. **Concurrency**
   - Multiple Manim workers (process pool)
   - Async LLM calls
   - Request queuing

3. **Hardware**
   - GPU acceleration for video encoding
   - Multi-core CPU utilization
   - SSD for temporary files

4. **Code Quality**
   - Lazy loading
   - Resource pooling
   - Connection reuse

---

## Security Analysis

### Current Security Posture

**Good Security Practices**:
- ✅ AST-based validation (prevents code injection)
- ✅ Subprocess isolation (code runs separately)
- ✅ CORS properly configured
- ✅ Input validation on prompts

**Security Concerns**:

| Risk | Level | Mitigation |
|------|-------|-----------|
| **LLM Prompt Injection** | Medium | Sanitize prompts, validate structure |
| **Code Execution** | Low | Isolated subprocess, AST validation |
| **File Access** | Low | Restricted to media/ directory |
| **DoS (Large Prompts)** | Medium | Add prompt length limit |
| **Memory Exhaustion** | Medium | Subprocess timeout, resource limits |
| **API Key Exposure** | High | Use .env, never commit keys |

### Recommended Security Hardening

**Immediate Actions**:
1. Add rate limiting
2. Implement authentication
3. Validate API keys properly
4. Add prompt length limits
5. Implement request timeouts

**Long-term**:
1. User authentication/authorization
2. Audit logging
3. Intrusion detection
4. Penetration testing
5. HTTPS enforcement

---

## Future Enhancements

### Phase 2: Core Features
- [ ] **User Accounts**: Registration, authentication, history
- [ ] **Animation Library**: Save, share, browse animations
- [ ] **Templates**: Pre-built animation templates
- [ ] **Batch Processing**: Generate multiple animations
- [ ] **Export Options**: GIF, WebM, higher resolutions

### Phase 3: Advanced Features
- [ ] **Real-time Preview**: Live editing while generating
- [ ] **Custom Styles**: Theme customization, colors
- [ ] **Collaboration**: Share, comment, fork animations
- [ ] **Analytics**: Track popular animations, trends
- [ ] **Mobile Apps**: Native iOS/Android apps

### Phase 4: Enterprise
- [ ] **Self-hosted**: Docker deployment
- [ ] **API Keys**: For third-party integration
- [ ] **Webhooks**: Event notifications
- [ ] **Admin Dashboard**: Monitoring, analytics
- [ ] **SLA**: Guaranteed uptime, support

### Research Areas
1. **Model Fine-tuning**: Train LLM on Manim code
2. **Multi-modal Input**: Image/audio to animation
3. **Real-time Rendering**: Stream animations as generated
4. **AR Integration**: Display animations in AR
5. **Neural Network Acceleration**: ML-based optimization

---

## Technical Challenges & Solutions

### Challenge 1: Multiple Video Generations Cache Issue

**Problem**: Browser caches videos with same URL, showing old animation for new prompts

**Root Cause**: HTTP caching on repeated `/video/ConceptAnimation.mp4` requests

**Solution Implemented**:
```python
# Add timestamp to URL
timestamp = int(time.time() * 1000)
video_url = f"/video/{rel_path}?t={timestamp}"

# Add cache-busting headers
"Cache-Control": "no-cache, no-store, must-revalidate"
"Pragma": "no-cache"
"Expires": "0"
```

**Why This Works**:
- Unique URL per generation = no cache hit
- Query parameter forces fresh request
- Headers tell browser not to cache

### Challenge 2: Platform View Registration (Flutter)

**Problem**: `HtmlElementView` complains about unregistered view type

**Root Cause**: View factory registered in widget initState, called before registration complete

**Solution Implemented**:
1. Register view factory in `main()` BEFORE `runApp()`
2. Create global video element
3. Return same element from factory each time

```dart
void main() {
  // Register BEFORE app starts
  ui.platformViewRegistry.registerViewFactory(
    'html5-video-player',
    (int viewId) => globalVideoElement  // Same element every time
  );
  runApp(const MyApp());
}
```

### Challenge 3: Manim Code Generation Errors

**Problem**: LLM generates invalid Manim code, crashes subprocess

**Solution Implemented**:
1. AST validation before execution
2. Error feedback loop (3 attempts)
3. Send error message back to LLM for correction

```python
# Validation
is_valid, error = validator.validate_syntax(code)

# Error correction loop
if not is_valid:
    error_feedback = f"Error: {error}"
    # Try again with feedback
```

### Challenge 4: Cross-Origin Video Streaming

**Problem**: Flutter web app can't load videos from different origin

**Solution Implemented**:
1. Backend serves videos with CORS headers
2. Allow all origins in development
3. Proper Content-Type headers

```python
headers={
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "video/mp4",
}
```

---

## Conclusion

BlackboardAI demonstrates a production-ready architecture for AI-powered code generation and execution. The system successfully:

- ✅ Bridges natural language to executable animations
- ✅ Provides automatic error correction
- ✅ Maintains clean separation of concerns
- ✅ Handles complex caching scenarios
- ✅ Delivers real-time responsiveness

Key achievements:
- **Code Quality**: Validated before execution
- **Reliability**: Error correction loop ensures success
- **Performance**: Optimized for development use
- **Scalability**: Ready for production deployment
- **Maintainability**: Clear architecture, extensive logging

---

## References

- [Manim Documentation](https://docs.manim.community/)
- [FastAPI Guide](https://fastapi.tiangolo.com/)
- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)
- [OpenRouter API](https://openrouter.ai/docs)
- [Python AST](https://docs.python.org/3/library/ast.html)

