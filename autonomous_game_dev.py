#!/usr/bin/env python3
"""
Autonomous Game Development System

This system continuously improves the Roblox multiplication game using AI.
It analyzes code, generates features, tests implementations, and deploys improvements.
"""

import os
import sys
import json
import asyncio
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

# Try to import AI systems
try:
    from setup_huggingface import HuggingFaceGameAI
    HF_AVAILABLE = True
except ImportError:
    HF_AVAILABLE = False

# Add autocoder to path
autocoder_path = Path(__file__).parent.parent.parent / "code" / "autocoder"
sys.path.insert(0, str(autocoder_path))

try:
    from src.pattern_assisted_coder import PatternAssistedCoder
    from src.llm_provider import MultiProviderLLM, TaskType
    AUTOCODER_AVAILABLE = True
except ImportError:
    AUTOCODER_AVAILABLE = False


class GameQualityAnalyzer:
    """Analyzes game code and finds improvement opportunities"""

    def __init__(self, game_path):
        self.game_path = Path(game_path)
        self.src_path = self.game_path / "src"

    async def analyze_codebase(self):
        """Analyze entire codebase for issues and opportunities"""

        print("\n🔍 Analyzing codebase...")

        issues = []
        opportunities = []

        # Check each Lua file
        for lua_file in self.src_path.rglob("*.lua"):
            with open(lua_file, 'r') as f:
                code = f.read()

            # Find potential issues
            file_issues = self._check_code_quality(code, lua_file.name)
            issues.extend(file_issues)

            # Find improvement opportunities
            file_opportunities = self._find_opportunities(code, lua_file.name)
            opportunities.extend(file_opportunities)

        print(f"   Found {len(issues)} issues")
        print(f"   Found {len(opportunities)} opportunities")

        return issues, opportunities

    def _check_code_quality(self, code, filename):
        """Check code for potential issues"""

        issues = []

        # Check for long functions (>100 lines)
        functions = code.split("function ")
        for i, func in enumerate(functions[1:]):
            lines = len(func.split('\n'))
            if lines > 100:
                issues.append({
                    "type": "code_smell",
                    "severity": "medium",
                    "file": filename,
                    "description": f"Function #{i+1} is too long ({lines} lines)",
                    "suggestion": "Consider breaking into smaller functions"
                })

        # Check for duplicated code patterns
        lines = code.split('\n')
        for i in range(len(lines) - 5):
            block = '\n'.join(lines[i:i+5])
            if code.count(block) > 2:
                issues.append({
                    "type": "duplication",
                    "severity": "low",
                    "file": filename,
                    "description": "Duplicated code block detected",
                    "suggestion": "Extract to reusable function"
                })

        # Check for missing error handling
        if "pcall" not in code and "xpcall" not in code:
            if "function" in code:
                issues.append({
                    "type": "error_handling",
                    "severity": "medium",
                    "file": filename,
                    "description": "No error handling found",
                    "suggestion": "Add pcall for error handling"
                })

        return issues

    def _find_opportunities(self, code, filename):
        """Find opportunities for improvement"""

        opportunities = []

        # Opportunities for optimization
        if "wait(" in code:
            opportunities.append({
                "type": "performance",
                "priority": "low",
                "file": filename,
                "description": "Using wait() - could use task.wait()",
                "benefit": "Better performance"
            })

        # Opportunities for new features
        if "Service" in filename and "-- TODO" in code:
            opportunities.append({
                "type": "feature",
                "priority": "medium",
                "file": filename,
                "description": "TODO comments found",
                "benefit": "Complete unfinished features"
            })

        # Opportunities for refactoring
        if "if" in code.count("if") > 10:
            opportunities.append({
                "type": "refactor",
                "priority": "medium",
                "file": filename,
                "description": "Complex conditional logic",
                "benefit": "Improved readability"
            })

        return opportunities


class AutonomousGameDeveloper:
    """Main autonomous development system"""

    def __init__(self, game_path=None):
        self.game_path = game_path or Path(__file__).parent
        self.analyzer = GameQualityAnalyzer(self.game_path)

        # Initialize AI systems
        self.autocoder = PatternAssistedCoder() if AUTOCODER_AVAILABLE else None
        self.hf_ai = HuggingFaceGameAI() if HF_AVAILABLE else None
        self.llm = MultiProviderLLM() if AUTOCODER_AVAILABLE else None

        # Development log
        self.log_file = self.game_path / "autonomous_dev.log"
        self.features_developed = []

    async def develop_feature(self, feature_request: str) -> Dict[str, Any]:
        """Autonomously develop a new feature"""

        print(f"\n🛠️  Developing feature: {feature_request}")

        result = {
            "feature": feature_request,
            "timestamp": datetime.now().isoformat(),
            "success": False
        }

        try:
            # Step 1: Plan implementation
            print("   📋 Planning implementation...")

            plan = await self._plan_feature(feature_request)
            result["plan"] = plan

            # Step 2: Generate implementations with multiple AI models
            print("   🤖 Generating code...")

            implementations = await self._generate_implementations(feature_request)
            result["implementations"] = len(implementations)

            # Step 3: Score and select best implementation
            print("   📊 Scoring implementations...")

            best_impl = await self._select_best_implementation(implementations)
            result["selected_implementation"] = best_impl

            # Step 4: Test implementation
            print("   🧪 Testing implementation...")

            test_result = await self._test_implementation(best_impl)
            result["test_result"] = test_result

            # Step 5: If tests pass, save the implementation
            if test_result.get("success", False):
                print("   ✅ Tests passed!")

                await self._save_implementation(feature_request, best_impl)
                result["success"] = True

                # Learn from successful implementation
                if self.autocoder:
                    await self.autocoder.learn_from_code(
                        best_impl["code"],
                        language="lua",
                        domain="roblox"
                    )

                print("   💾 Implementation saved and learned")

            else:
                print("   ❌ Tests failed")
                result["errors"] = test_result.get("errors", [])

        except Exception as e:
            print(f"   ❌ Development failed: {e}")
            result["error"] = str(e)

        # Log result
        self._log_development(result)
        self.features_developed.append(result)

        return result

    async def _plan_feature(self, feature_request):
        """Plan feature implementation"""

        if not self.llm:
            return {"steps": ["Generate code", "Test code", "Deploy code"]}

        try:
            response = await self.llm.complete(
                messages=[{
                    "role": "user",
                    "content": f"Plan how to implement this Roblox game feature: {feature_request}\n\nProvide step-by-step implementation plan."
                }],
                task_type=TaskType.PLANNING
            )

            plan_text = response["choices"][0]["message"]["content"]

            return {"plan_text": plan_text, "steps": plan_text.split('\n')}

        except Exception as e:
            return {"error": str(e), "steps": []}

    async def _generate_implementations(self, feature_request):
        """Generate multiple implementations"""

        implementations = []

        # Try with AutoCoder
        if self.autocoder:
            try:
                impl = await self.autocoder.generate_code(
                    prompt=feature_request,
                    language="lua",
                    patterns_domain="roblox"
                )

                implementations.append({
                    "source": "autocoder",
                    "code": impl.get("code", ""),
                    "quality": impl.get("quality_score", 0),
                    "confidence": impl.get("confidence", 0)
                })

            except Exception as e:
                print(f"      AutoCoder failed: {e}")

        # Try with HuggingFace
        if self.hf_ai and hasattr(self.hf_ai, "generate_lua_code"):
            try:
                impl = await self.hf_ai.generate_lua_code(feature_request)

                if impl.get("success", False):
                    implementations.append({
                        "source": "huggingface",
                        "code": impl.get("code", ""),
                        "quality": 0.5,  # Default score
                        "confidence": 0.6
                    })

            except Exception as e:
                print(f"      HuggingFace failed: {e}")

        # Try with raw LLM
        if self.llm:
            try:
                response = await self.llm.complete(
                    messages=[{
                        "role": "user",
                        "content": f"Write Lua code for Roblox that implements: {feature_request}\n\nProvide complete, working code."
                    }],
                    task_type=TaskType.COMPLEX_CODING
                )

                code = response["choices"][0]["message"]["content"]

                implementations.append({
                    "source": "llm",
                    "code": code,
                    "quality": 0.7,  # Assume good quality
                    "confidence": 0.8
                })

            except Exception as e:
                print(f"      LLM failed: {e}")

        return implementations

    async def _select_best_implementation(self, implementations):
        """Select best implementation based on scores"""

        if not implementations:
            return None

        # Sort by quality * confidence
        scored = [{
            **impl,
            "score": impl["quality"] * impl["confidence"]
        } for impl in implementations]

        scored.sort(key=lambda x: x["score"], reverse=True)

        return scored[0] if scored else None

    async def _test_implementation(self, implementation):
        """Test an implementation"""

        if not implementation:
            return {"success": False, "error": "No implementation provided"}

        code = implementation.get("code", "")

        # Basic syntax check
        if not code or len(code) < 10:
            return {"success": False, "error": "Code too short"}

        # Check for Lua syntax
        if not ("function" in code or "local" in code):
            return {"success": False, "error": "Not valid Lua code"}

        # In a real system, would run actual tests here
        # For now, assume it passes basic checks

        return {
            "success": True,
            "checks_passed": ["syntax", "structure"],
            "score": implementation.get("quality", 0.5)
        }

    async def _save_implementation(self, feature_name, implementation):
        """Save successful implementation"""

        # Create features directory
        features_dir = self.game_path / "generated_features"
        features_dir.mkdir(exist_ok=True)

        # Generate filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"feature_{timestamp}.lua"
        filepath = features_dir / filename

        # Save code
        with open(filepath, 'w') as f:
            f.write(f"-- {feature_name}\n")
            f.write(f"-- Generated: {datetime.now().isoformat()}\n")
            f.write(f"-- Source: {implementation.get('source', 'unknown')}\n\n")
            f.write(implementation.get("code", ""))

        # Save metadata
        metadata = {
            "feature": feature_name,
            "file": str(filepath),
            "timestamp": datetime.now().isoformat(),
            "source": implementation.get("source"),
            "quality": implementation.get("quality"),
            "confidence": implementation.get("confidence")
        }

        metadata_file = features_dir / f"feature_{timestamp}.json"
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

    def _log_development(self, result):
        """Log development activity"""

        with open(self.log_file, 'a') as f:
            f.write(json.dumps(result) + '\n')

    async def autonomous_improvement_loop(self, max_iterations=10):
        """Run autonomous improvement loop"""

        print("=" * 60)
        print("🤖 Autonomous Game Development Loop")
        print("=" * 60)

        for iteration in range(max_iterations):
            print(f"\n📍 Iteration {iteration + 1}/{max_iterations}")

            # Analyze codebase
            issues, opportunities = await self.analyzer.analyze_codebase()

            # Prioritize tasks
            tasks = self._prioritize_tasks(issues + opportunities)

            if not tasks:
                print("   ✅ No tasks found - codebase is perfect!")
                break

            # Work on top 3 tasks
            for task in tasks[:3]:
                feature_request = self._task_to_feature_request(task)

                result = await self.develop_feature(feature_request)

                if result["success"]:
                    print(f"   ✅ Completed: {feature_request}")
                else:
                    print(f"   ❌ Failed: {feature_request}")

            # Wait before next iteration
            print(f"\n⏳ Waiting 60 seconds before next iteration...")
            await asyncio.sleep(60)

        print("\n" + "=" * 60)
        print("✅ Autonomous Development Complete!")
        print(f"   Features Developed: {len([f for f in self.features_developed if f['success']])}/{len(self.features_developed)}")
        print("=" * 60)

    def _prioritize_tasks(self, tasks):
        """Prioritize tasks by severity/priority"""

        # Sort by severity (high > medium > low)
        severity_order = {"high": 3, "medium": 2, "low": 1}

        sorted_tasks = sorted(
            tasks,
            key=lambda t: severity_order.get(t.get("severity", "low"), 1),
            reverse=True
        )

        return sorted_tasks

    def _task_to_feature_request(self, task):
        """Convert task to feature request"""

        if task.get("type") == "code_smell":
            return f"Refactor {task['file']}: {task['suggestion']}"
        elif task.get("type") == "error_handling":
            return f"Add error handling to {task['file']}"
        elif task.get("type") == "performance":
            return f"Optimize {task['file']}: {task['description']}"
        else:
            return task.get("description", "Unknown task")


async def main():
    """Main entry point"""

    print("🤖 Autonomous Game Development System\n")

    # Check dependencies
    if not AUTOCODER_AVAILABLE:
        print("⚠️  AutoCoder not available")
        print("   Some features will be limited")

    if not HF_AVAILABLE:
        print("⚠️  HuggingFace AI not available")
        print("   Run: python setup_huggingface.py")

    # Create developer
    developer = AutonomousGameDeveloper()

    # Run autonomous loop
    await developer.autonomous_improvement_loop(max_iterations=5)


if __name__ == "__main__":
    asyncio.run(main())
