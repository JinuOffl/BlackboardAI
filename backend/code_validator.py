import ast
from typing import Tuple, Optional

class CodeValidator:
    """Validates Python code for syntax and Manim requirements"""
    
    def __init__(self):
        print("[VALIDATOR] CodeValidator initialized")
    
    def validate_syntax(self, code: str) -> Tuple[bool, Optional[str]]:
        """Validates Python code syntax using AST"""
        print(f"[VALIDATOR] Starting validation... ({len(code)} chars)")
        
        if not code or not code.strip():
            return False, "Code is empty"
        
        try:
            tree = ast.parse(code)
            print(f"[VALIDATOR] ✓ AST parsing successful")
            
            has_import = False
            has_scene_class = False
            has_construct_method = False
            
            for node in ast.walk(tree):
                if isinstance(node, ast.ImportFrom) and node.module == "manim":
                    has_import = True
                    print("[VALIDATOR] ✓ Found manim import")
                
                if isinstance(node, ast.ClassDef):
                    if any(isinstance(b, ast.Name) and b.id == "Scene" for b in node.bases):
                        has_scene_class = True
                        print(f"[VALIDATOR] ✓ Found Scene class: {node.name}")
                        
                        for item in node.body:
                            if isinstance(item, ast.FunctionDef) and item.name == "construct":
                                has_construct_method = True
                                print("[VALIDATOR] ✓ Found construct() method")
            
            if not has_import:
                return False, "Missing 'from manim import *'"
            if not has_scene_class:
                return False, "No Scene class found"
            if not has_construct_method:
                return False, "Scene class must have construct(self) method"
            
            print("[VALIDATOR] ✓✓✓ All checks passed!")
            return True, None
            
        except SyntaxError as e:
            return False, f"Syntax Error at line {e.lineno}: {e.msg}"
        except IndentationError as e:
            return False, f"Indentation Error at line {e.lineno}: {e.msg}"
        except Exception as e:
            return False, f"Validation Error: {str(e)}"
    
    def extract_class_name(self, code: str) -> Optional[str]:
        """Extract Scene class name"""
        print("[VALIDATOR] Extracting class name...")
        try:
            tree = ast.parse(code)
            for node in ast.walk(tree):
                if isinstance(node, ast.ClassDef):
                    if any(isinstance(b, ast.Name) and b.id == "Scene" for b in node.bases):
                        print(f"[VALIDATOR] Class name: {node.name}")
                        return node.name
        except:
            pass
        return None

print("[VALIDATOR] Module loaded")