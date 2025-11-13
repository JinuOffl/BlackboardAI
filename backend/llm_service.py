import httpx
from config import Config

class LLMService:
    """OpenRouter AI integration"""
    
    def __init__(self):
        self.api_key = Config.OPENROUTER_API_KEY
        self.base_url = Config.OPENROUTER_BASE_URL
        self.model = Config.DEFAULT_MODEL
        print(f"[LLM] Initialized with model: {self.model}")
        
        if not self.api_key:
            print("[LLM] ⚠️  WARNING: OPENROUTER_API_KEY not set!")
    
    async def generate_manim_code(self, user_prompt: str, error_feedback: str = None) -> str:
        """Generate Manim code from prompt"""
        print(f"[LLM] Generating code for: '{user_prompt[:50]}...'")
        if error_feedback:
            print(f"[LLM] With error feedback: {error_feedback}")
        
        system_prompt = """You are an expert Manim code generator for blackboardAI.

CRITICAL RULES:
1. Output ONLY executable Python code - NO markdown, NO explanations
2. Start with: from manim import *
3. Create ONE class ConceptAnimation(Scene)
4. Implement construct(self) method
5. Manim Community v0.19.0 compatible
6. NO self.camera.frame or self.camera.animate
7. 5-10 seconds total duration
8. Use self.wait() for pacing
9. Colors: BLUE, RED, GREEN, YELLOW, ORANGE, TEAL, PURPLE
10. Avoid overlapping with buff parameter

TEMPLATE:
from manim import *

class ConceptAnimation(Scene):
    def construct(self):
        title = Text("Title", font_size=60)
        self.play(FadeIn(title))
        self.wait(2)
        # more animations

Output ONLY Python code."""
        
        user_message = user_prompt
        if error_feedback:
            user_message = f"""Previous code had errors:
{error_feedback}

Fix code for: {user_prompt}

Output ONLY corrected code."""
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        
        payload = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            "temperature": Config.TEMPERATURE,
            "max_tokens": Config.MAX_TOKENS,
        }
        
        try:
            print("[LLM] Sending API request...")
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    f"{self.base_url}/chat/completions",
                    headers=headers,
                    json=payload
                )
                
                print(f"[LLM] Status: {response.status_code}")
                
                if response.status_code != 200:
                    raise Exception(f"API error: {response.text}")
                
                result = response.json()
                code = result["choices"][0]["message"]["content"]
                code = self._clean_code(code)
                
                print(f"[LLM] ✓ Generated {len(code)} chars")
                return code
                
        except Exception as e:
            print(f"[LLM] ❌ Error: {str(e)}")
            raise
    
    def _clean_code(self, code: str) -> str:
        """Remove markdown blocks"""
        print("[LLM] Cleaning code...")
        
        if "```python" in code:
            code = code.split("```python")[1].split("```")[0]
        elif "```" in code:
            code = code.split("```")[1].split("```")[0]
        
        return code.strip()

print("[LLM] Module loaded")