import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # OpenRouter API Configuration
    OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")
    OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1"
    
    # LLM Model Configuration
    DEFAULT_MODEL = "meta-llama/llama-3.3-70b-instruct:free"
    TEMPERATURE = 0.7
    MAX_TOKENS = 2000
    
    # Manim Configuration
    MANIM_OUTPUT_DIR = "media/videos"
    MANIM_QUALITY = "l"
    MANIM_PREVIEW = False
    
    # Application Configuration
    MAX_CORRECTION_ATTEMPTS = 3
    BACKEND_PORT = 8000
    ALLOWED_ORIGINS = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://localhost:53772",
        "http://localhost",
        "http://127.0.0.1",
    ]
    
    LOG_LEVEL = "INFO"

print("[CONFIG] Configuration loaded")