from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
import uvicorn
from pathlib import Path

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
    allow_origins=["*"],         # <--- universal access on dev
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
    print("\\n" + "=" * 80)
    print(f"[MAIN] NEW REQUEST: {request.prompt}")
    print("=" * 80)
    
    user_prompt = request.prompt.strip()
    
    if not user_prompt:
        raise HTTPException(status_code=400, detail="Prompt cannot be empty")
    
    error_feedback = None
    attempts = 0
    
    while attempts < Config.MAX_CORRECTION_ATTEMPTS:
        attempts += 1
        print(f"\\n[MAIN] === ATTEMPT {attempts}/{Config.MAX_CORRECTION_ATTEMPTS} ===")
        
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
            
            return AnimationResponse(
                status="success",
                message="Animation generated successfully",
                code=code,
                video_url=f"/video/{Path(video_path).name}",
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

if __name__ == "__main__":
    print(f"\\n[MAIN] Starting server on port {Config.BACKEND_PORT}...")
    print(f"[MAIN] Allowed origins: {Config.ALLOWED_ORIGINS}")
    print("=" * 80)
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=Config.BACKEND_PORT,
        log_level=Config.LOG_LEVEL.lower()
    )