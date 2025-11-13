import os
import subprocess
import tempfile
from pathlib import Path
from config import Config
from code_validator import CodeValidator

class ManimService:
    """Manim code execution and rendering"""
    
    def __init__(self):
        self.validator = CodeValidator()
        self.output_dir = Config.MANIM_OUTPUT_DIR
        print(f"[MANIM] ManimService initialized")
        print(f"[MANIM] Output directory: {self.output_dir}")
    
    async def render_animation(self, code: str, scene_name: str = "ConceptAnimation") -> str:
        """
        Render Manim animation from code
        
        Returns:
            Path to rendered video file
        """
        print(f"[MANIM] Starting render for scene: {scene_name}")
        print(f"[MANIM] Code length: {len(code)} characters")
        
        # Create temporary Python file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(code)
            temp_file = f.name
        
        print(f"[MANIM] Created temp file: {temp_file}")
        
        try:
            # Build manim command
            quality_flag = f"-q{Config.MANIM_QUALITY}"
            command = [
                "manim",
                quality_flag,
                temp_file,
                scene_name
            ]
            
            print(f"[MANIM] Executing command: {' '.join(command)}")
            
            # Run manim programmatically
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=120
            )
            
            print(f"[MANIM] Return code: {result.returncode}")
            
            if result.stdout:
                print(f"[MANIM] STDOUT:\\n{result.stdout}")
            if result.stderr:
                print(f"[MANIM] STDERR:\\n{result.stderr}")
            
            if result.returncode != 0:
                raise Exception(f"Manim render failed: {result.stderr}")
            
            # Find the generated video file
            video_path = self._find_video_file(temp_file, scene_name)
            
            if not video_path:
                raise Exception("Could not find rendered video file")
            
            print(f"[MANIM] ✓ Video rendered: {video_path}")
            return video_path
            
        except subprocess.TimeoutExpired:
            print("[MANIM] ❌ Render timeout (120s)")
            raise Exception("Manim render timeout")
        except Exception as e:
            print(f"[MANIM] ❌ Render error: {str(e)}")
            raise
        finally:
            # Clean up temp file
            try:
                os.unlink(temp_file)
                print(f"[MANIM] Cleaned up temp file")
            except:
                pass
    
    def _find_video_file(self, script_path: str, scene_name: str) -> str:
        """Find the rendered video file"""
        print("[MANIM] Searching for video file...")
        
        # Manim output structure: media/videos/<script_name>/<quality>/<scene_name>.mp4
        script_name = Path(script_path).stem
        search_dir = Path(self.output_dir) / script_name
        
        if not search_dir.exists():
            print(f"[MANIM] Search directory doesn't exist: {search_dir}")
            return None
        
        # Search for video file
        for file_path in search_dir.rglob(f"{scene_name}.mp4"):
            print(f"[MANIM] Found video: {file_path}")
            return str(file_path)
        
        print("[MANIM] No video file found")
        return None

print("[MANIM] Module loaded")