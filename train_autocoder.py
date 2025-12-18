#!/usr/bin/env python3
"""
Train AutoCoder on Roblox Multiplication Game Code

This script trains the AutoCoder AI system to understand our game patterns
and generate high-quality Lua code for Roblox games.
"""

import os
import sys
import json
import asyncio
from pathlib import Path

# Add autocoder to path
autocoder_path = Path(__file__).parent.parent.parent / "code" / "autocoder"
sys.path.insert(0, str(autocoder_path))

try:
    from src.pattern_assisted_coder import PatternAssistedCoder
    from src.llm_provider import MultiProviderLLM, TaskType
except ImportError:
    print("❌ Error: Could not import AutoCoder modules")
    print(f"   Looking in: {autocoder_path}")
    print("   Make sure AutoCoder is installed in /projects/code/autocoder")
    sys.exit(1)


class RobloxGameTrainer:
    """Trains AI models on Roblox game code"""

    def __init__(self, game_path=None):
        self.game_path = game_path or Path(__file__).parent
        self.src_path = self.game_path / "src"
        self.coder = PatternAssistedCoder()
        self.llm = MultiProviderLLM()

        print(f"🎮 Roblox Game Trainer")
        print(f"   Game Path: {self.game_path}")
        print(f"   Source Path: {self.src_path}")

    async def collect_training_data(self):
        """Collect all Lua code from the game"""

        training_data = []

        print("\n📂 Collecting training data...")

        # Find all Lua files
        lua_files = list(self.src_path.rglob("*.lua"))

        for lua_file in lua_files:
            try:
                with open(lua_file, 'r', encoding='utf-8') as f:
                    code = f.read()

                # Extract metadata
                relative_path = lua_file.relative_to(self.game_path)
                file_info = {
                    "file": str(relative_path),
                    "code": code,
                    "lines": len(code.split('\n')),
                    "category": self._categorize_file(lua_file.name),
                    "service": self._get_service_type(relative_path)
                }

                training_data.append(file_info)

                print(f"   ✅ {relative_path} ({file_info['lines']} lines)")

            except Exception as e:
                print(f"   ❌ {lua_file.name}: {e}")

        print(f"\n📊 Collected {len(training_data)} files")
        return training_data

    def _categorize_file(self, filename):
        """Categorize file by type"""
        if "Manager" in filename or "Service" in filename:
            return "service"
        elif "UI" in filename or "GUI" in filename:
            return "ui"
        elif "Config" in filename:
            return "config"
        elif "Controller" in filename:
            return "controller"
        else:
            return "utility"

    def _get_service_type(self, path):
        """Determine Roblox service"""
        path_str = str(path)
        if "ServerScriptService" in path_str:
            return "server"
        elif "StarterGui" in path_str:
            return "client_ui"
        elif "StarterPlayer" in path_str:
            return "client_character"
        elif "ReplicatedStorage" in path_str:
            return "shared"
        else:
            return "unknown"

    async def train_patterns(self, training_data):
        """Train AutoCoder on game patterns"""

        print("\n🧠 Training pattern recognition...")

        patterns_learned = 0

        for file_info in training_data:
            try:
                # Feed code to pattern learner
                await self.coder.learn_from_code(
                    code=file_info["code"],
                    language="lua",
                    domain="roblox",
                    metadata={
                        "file": file_info["file"],
                        "category": file_info["category"],
                        "service": file_info["service"]
                    }
                )

                patterns_learned += 1
                print(f"   ✅ Learned patterns from {file_info['file']}")

            except Exception as e:
                print(f"   ❌ Failed to learn from {file_info['file']}: {e}")

        print(f"\n📈 Learned patterns from {patterns_learned}/{len(training_data)} files")

    async def extract_common_patterns(self):
        """Extract and analyze common patterns"""

        print("\n🔍 Extracting common patterns...")

        try:
            patterns = await self.coder.analyze_patterns(
                domain="roblox",
                categories=["service", "ui", "config", "controller"]
            )

            print(f"\n📋 Found {len(patterns)} common patterns:")
            for pattern in patterns[:10]:  # Show top 10
                print(f"   • {pattern.get('name', 'Unknown')}")
                print(f"     Used in: {pattern.get('frequency', 0)} places")
                print(f"     Quality: {pattern.get('quality_score', 0):.2f}")

            return patterns

        except Exception as e:
            print(f"   ⚠️  Could not extract patterns: {e}")
            return []

    async def test_generation(self):
        """Test code generation with learned patterns"""

        print("\n🧪 Testing code generation...")

        test_prompts = [
            "Create a new object type called Robot worth 15 currency",
            "Add a new upgrade that increases spawn rate",
            "Create a notification system for achievements",
            "Add a leaderboard UI component"
        ]

        results = []

        for prompt in test_prompts:
            try:
                print(f"\n   📝 Prompt: {prompt}")

                # Generate code
                result = await self.coder.generate_code(
                    prompt=prompt,
                    language="lua",
                    patterns_domain="roblox"
                )

                quality = result.get("quality_score", 0)
                confidence = result.get("confidence", 0)

                print(f"      Quality: {quality:.2f}")
                print(f"      Confidence: {confidence:.2f}")
                print(f"      Lines: {len(result.get('code', '').split('\\n'))}")

                results.append({
                    "prompt": prompt,
                    "quality": quality,
                    "confidence": confidence,
                    "success": quality > 0.7 and confidence > 0.6
                })

            except Exception as e:
                print(f"      ❌ Generation failed: {e}")
                results.append({
                    "prompt": prompt,
                    "success": False,
                    "error": str(e)
                })

        # Summary
        successes = sum(1 for r in results if r.get("success", False))
        print(f"\n📊 Test Results: {successes}/{len(test_prompts)} successful")

        return results

    async def save_trained_model(self):
        """Save the trained patterns"""

        print("\n💾 Saving trained model...")

        try:
            output_path = self.game_path / "roblox_game_patterns.json"

            # Save patterns
            await self.coder.save_patterns(str(output_path))

            print(f"   ✅ Saved to: {output_path}")

            # Also save training report
            report_path = self.game_path / "training_report.json"

            report = {
                "game": "Roblox Multiplication Game",
                "files_trained": len(list(self.src_path.rglob("*.lua"))),
                "domain": "roblox",
                "language": "lua",
                "timestamp": str(asyncio.get_event_loop().time()),
                "model_path": str(output_path)
            }

            with open(report_path, 'w') as f:
                json.dump(report, f, indent=2)

            print(f"   ✅ Report saved to: {report_path}")

        except Exception as e:
            print(f"   ❌ Failed to save: {e}")

    async def run_full_training(self):
        """Run the complete training pipeline"""

        print("=" * 60)
        print("🤖 AutoCoder Training Pipeline")
        print("   Training on: Roblox Multiplication Game")
        print("=" * 60)

        # Step 1: Collect data
        training_data = await self.collect_training_data()

        if not training_data:
            print("❌ No training data found!")
            return False

        # Step 2: Train patterns
        await self.train_patterns(training_data)

        # Step 3: Extract patterns
        patterns = await self.extract_common_patterns()

        # Step 4: Test generation
        test_results = await self.test_generation()

        # Step 5: Save model
        await self.save_trained_model()

        # Step 6: Summary
        print("\n" + "=" * 60)
        print("✅ Training Complete!")
        print("=" * 60)
        print(f"   Files Trained: {len(training_data)}")
        print(f"   Patterns Learned: {len(patterns)}")
        print(f"   Test Success Rate: {sum(1 for r in test_results if r.get('success', False))}/{len(test_results)}")
        print(f"\n   Model saved to: roblox_game_patterns.json")
        print(f"   Report saved to: training_report.json")
        print("\n🚀 Ready to generate Roblox game features!")

        return True


async def main():
    """Main entry point"""

    print("🎮 Roblox Game AI Training System\n")

    # Check if AutoCoder is available
    try:
        from src.pattern_assisted_coder import PatternAssistedCoder
        print("✅ AutoCoder found and loaded")
    except ImportError:
        print("❌ AutoCoder not found!")
        print("\n📝 Setup Instructions:")
        print("   1. Make sure AutoCoder is in /projects/code/autocoder")
        print("   2. Install dependencies: cd autocoder && pip install -r requirements.txt")
        print("   3. Set up API keys (see AI_INTEGRATION_PLAN.md)")
        return

    # Run training
    trainer = RobloxGameTrainer()

    success = await trainer.run_full_training()

    if success:
        print("\n✅ Training successful!")
        print("\n📚 Next Steps:")
        print("   1. Test generation: python generate_feature.py")
        print("   2. Set up HuggingFace: python setup_huggingface.py")
        print("   3. Deploy autonomous system: python autonomous_game_dev.py")
    else:
        print("\n❌ Training failed!")
        print("   Check the errors above and try again")


if __name__ == "__main__":
    asyncio.run(main())
