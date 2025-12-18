#!/usr/bin/env python3
"""
Set up HuggingFace AI models for Roblox game development

This script downloads and configures FREE HuggingFace models that can generate
code, improve existing code, and create game content.
"""

import os
import sys
import json
import asyncio
from pathlib import Path

try:
    from transformers import (
        pipeline,
        AutoModelForCausalLM,
        AutoTokenizer,
        AutoModel
    )
    import torch
    TRANSFORMERS_AVAILABLE = True
except ImportError:
    TRANSFORMERS_AVAILABLE = False


class HuggingFaceGameAI:
    """AI system using HuggingFace models for game development"""

    def __init__(self):
        self.models = {}
        self.device = "cuda" if torch.cuda.is_available() else "cpu"

        print(f"🤗 HuggingFace Game AI")
        print(f"   Device: {self.device}")
        print(f"   GPU Available: {torch.cuda.is_available()}")

    async def setup_code_generation(self):
        """Set up code generation model"""

        print("\n📦 Setting up code generation...")

        try:
            # Use smaller model that works on CPU
            model_name = "Salesforce/codegen-350M-mono"

            print(f"   Loading {model_name}...")

            self.models["code_gen"] = pipeline(
                "text-generation",
                model=model_name,
                device=self.device,
                torch_dtype=torch.float16 if self.device == "cuda" else torch.float32
            )

            print(f"   ✅ Code generation model loaded")

            return True

        except Exception as e:
            print(f"   ❌ Failed to load code model: {e}")
            return False

    async def setup_code_understanding(self):
        """Set up code understanding model"""

        print("\n📦 Setting up code understanding...")

        try:
            model_name = "microsoft/codebert-base"

            print(f"   Loading {model_name}...")

            tokenizer = AutoTokenizer.from_pretrained(model_name)
            model = AutoModel.from_pretrained(model_name)

            self.models["code_bert"] = {
                "tokenizer": tokenizer,
                "model": model
            }

            print(f"   ✅ Code understanding model loaded")

            return True

        except Exception as e:
            print(f"   ❌ Failed to load understanding model: {e}")
            return False

    async def setup_text_generation(self):
        """Set up text generation for game content"""

        print("\n📦 Setting up text generation...")

        try:
            model_name = "distilgpt2"  # Smaller, faster

            print(f"   Loading {model_name}...")

            self.models["text_gen"] = pipeline(
                "text-generation",
                model=model_name,
                device=self.device
            )

            print(f"   ✅ Text generation model loaded")

            return True

        except Exception as e:
            print(f"   ❌ Failed to load text model: {e}")
            return False

    async def generate_lua_code(self, prompt, max_length=200):
        """Generate Lua code"""

        if "code_gen" not in self.models:
            return {"error": "Code generation model not loaded"}

        try:
            # Format prompt for Lua
            lua_prompt = f"-- {prompt}\nlocal function"

            result = self.models["code_gen"](
                lua_prompt,
                max_length=max_length,
                num_return_sequences=1,
                temperature=0.7,
                do_sample=True
            )

            code = result[0]["generated_text"]

            return {
                "prompt": prompt,
                "code": code,
                "success": True
            }

        except Exception as e:
            return {
                "prompt": prompt,
                "error": str(e),
                "success": False
            }

    async def improve_code(self, code_snippet):
        """Suggest improvements to code"""

        if "code_gen" not in self.models:
            return {"error": "Code model not loaded"}

        try:
            prompt = f"-- Improve this code:\n{code_snippet}\n\n-- Improved version:\n"

            result = self.models["code_gen"](
                prompt,
                max_length=len(code_snippet) + 100,
                num_return_sequences=1,
                temperature=0.5
            )

            improved_code = result[0]["generated_text"]

            return {
                "original": code_snippet,
                "improved": improved_code,
                "success": True
            }

        except Exception as e:
            return {
                "error": str(e),
                "success": False
            }

    async def generate_game_content(self, content_type, context):
        """Generate game content (dialogue, descriptions, etc.)"""

        if "text_gen" not in self.models:
            return {"error": "Text generation model not loaded"}

        try:
            prompt = f"Generate {content_type}: {context}\n\nResult:"

            result = self.models["text_gen"](
                prompt,
                max_length=150,
                num_return_sequences=3,
                temperature=0.8,
                do_sample=True
            )

            content = [r["generated_text"] for r in result]

            return {
                "type": content_type,
                "context": context,
                "generated": content,
                "success": True
            }

        except Exception as e:
            return {
                "error": str(e),
                "success": False
            }

    async def test_models(self):
        """Test all loaded models"""

        print("\n🧪 Testing models...")

        tests = [
            {
                "name": "Code Generation",
                "test": lambda: self.generate_lua_code("create a function that doubles a number")
            },
            {
                "name": "Code Improvement",
                "test": lambda: self.improve_code("function add(a, b) return a + b end")
            },
            {
                "name": "Content Generation",
                "test": lambda: self.generate_game_content("NPC dialogue", "friendly shopkeeper")
            }
        ]

        results = []

        for test in tests:
            print(f"\n   📝 Testing: {test['name']}")

            try:
                result = await test["test"]()

                if result.get("success", False):
                    print(f"      ✅ Success")
                    results.append(True)
                else:
                    print(f"      ❌ Failed: {result.get('error', 'Unknown')}")
                    results.append(False)

            except Exception as e:
                print(f"      ❌ Error: {e}")
                results.append(False)

        success_rate = sum(results) / len(results) if results else 0
        print(f"\n📊 Test Results: {sum(results)}/{len(results)} ({success_rate*100:.0f}%)")

        return success_rate > 0.5

    async def save_config(self):
        """Save configuration"""

        print("\n💾 Saving configuration...")

        config = {
            "models_loaded": list(self.models.keys()),
            "device": self.device,
            "gpu_available": torch.cuda.is_available(),
            "capabilities": {
                "code_generation": "code_gen" in self.models,
                "code_understanding": "code_bert" in self.models,
                "text_generation": "text_gen" in self.models
            }
        }

        config_path = Path(__file__).parent / "huggingface_config.json"

        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)

        print(f"   ✅ Saved to: {config_path}")

    async def run_setup(self):
        """Run full setup"""

        print("=" * 60)
        print("🤗 HuggingFace AI Setup for Roblox Games")
        print("=" * 60)

        # Setup models
        await self.setup_code_generation()
        await self.setup_code_understanding()
        await self.setup_text_generation()

        # Test models
        success = await self.test_models()

        # Save config
        await self.save_config()

        print("\n" + "=" * 60)

        if success:
            print("✅ Setup Complete!")
            print("=" * 60)
            print(f"   Models Loaded: {len(self.models)}")
            print(f"   Device: {self.device}")
            print("\n🚀 Ready to generate game features!")
            print("\n📚 Next Steps:")
            print("   1. Run: python generate_feature.py")
            print("   2. Or use in code:")
            print("      from setup_huggingface import HuggingFaceGameAI")
            print("      ai = HuggingFaceGameAI()")
            print("      result = await ai.generate_lua_code('your prompt')")
        else:
            print("⚠️  Setup Complete with Warnings")
            print("=" * 60)
            print("   Some models failed to load")
            print("   Check errors above for details")

        return success


async def main():
    """Main entry point"""

    print("🤗 HuggingFace AI Setup for Roblox Games\n")

    # Check if transformers is installed
    if not TRANSFORMERS_AVAILABLE:
        print("❌ HuggingFace Transformers not installed!")
        print("\n📝 Installation Instructions:")
        print("   pip install transformers torch")
        print("\n   For GPU support:")
        print("   pip install transformers torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118")
        return

    print("✅ HuggingFace Transformers found\n")

    # Run setup
    ai = HuggingFaceGameAI()
    success = await ai.run_setup()

    if not success:
        print("\n⚠️  Some issues occurred during setup")
        print("   The system may still work with limited functionality")


if __name__ == "__main__":
    asyncio.run(main())
