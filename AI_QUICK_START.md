# 🚀 AI Quick Start - Get Running in 15 Minutes

Get your autonomous AI game development system running quickly.

---

## ⚡ Prerequisites (5 minutes)

### 1. Check Python

```bash
python --version  # Need 3.8+
```

### 2. Install Core Dependencies

```bash
cd /mnt/e/projects/roblox/multiplication-game

pip install asyncio pathlib
```

### 3. Set Up FREE API Keys (Optional but Recommended)

**Groq (FREE - Recommended):**
```bash
# Get at: https://console.groq.com
export GROQ_API_KEY="your_key_here"
```

**GitHub Models (FREE - Best):**
```bash
# Get at: https://github.com/settings/tokens
export GITHUB_TOKEN="ghp_your_token"
```

**Google Gemini (FREE - 1M tokens/day):**
```bash
# Get at: https://makersuite.google.com/app/apikey
export GEMINI_API_KEY="your_key"
```

---

## 🎯 Option 1: Quick Demo (2 minutes)

Just want to see it work?

```bash
# Run minimal demo without AutoCoder
python -c "
import asyncio
from pathlib import Path

async def demo():
    print('🎮 Autonomous Game AI Demo\n')

    # Scan game files
    src = Path('src')
    lua_files = list(src.rglob('*.lua'))

    print(f'✅ Found {len(lua_files)} Lua files')

    for file in lua_files[:5]:
        print(f'   • {file.name}')

    print('\n✅ AI system would train on these files')
    print('✅ Generate new features')
    print('✅ Improve code quality')
    print('\n📝 Next: Run full setup to enable AI features')

asyncio.run(demo())
"
```

---

## 🚀 Option 2: Full Setup (15 minutes)

### Step 1: Train AutoCoder (5 min)

```bash
# Train AI on your game code
python train_autocoder.py
```

**Expected Output:**
```
🤖 AutoCoder Training Pipeline
✅ Collected 14 files
✅ Learned patterns
✅ Training complete!
💾 Model saved to: roblox_game_patterns.json
```

### Step 2: Set Up HuggingFace (5 min)

```bash
# Install transformers
pip install transformers torch

# Set up models
python setup_huggingface.py
```

**Expected Output:**
```
🤗 HuggingFace AI Setup
✅ Code generation model loaded
✅ Text generation model loaded
✅ Setup Complete!
```

### Step 3: Run Autonomous Developer (5 min)

```bash
# Start autonomous improvement
python autonomous_game_dev.py
```

**Expected Output:**
```
🤖 Autonomous Game Development Loop
📍 Iteration 1/5
🛠️  Developing feature: Add error handling to Config.lua
✅ Tests passed!
💾 Implementation saved
```

---

## 🎮 What Can You Do?

### 1. Generate New Features

```python
python -c "
from autonomous_game_dev import AutonomousGameDeveloper
import asyncio

async def generate():
    dev = AutonomousGameDeveloper()
    result = await dev.develop_feature('Add a new Phoenix object worth 100 currency')
    print(result)

asyncio.run(generate())
"
```

### 2. Improve Existing Code

```bash
# Auto-improve all code
python autonomous_game_dev.py
```

### 3. Generate Game Content

```python
from setup_huggingface import HuggingFaceGameAI
import asyncio

async def generate_content():
    ai = HuggingFaceGameAI()
    result = await ai.generate_game_content('NPC dialogue', 'Shop keeper offering upgrades')
    print(result['generated'][0])

asyncio.run(generate_content())
```

---

## 🔧 Troubleshooting

### "Cannot import AutoCoder"

**Solution:** AutoCoder is in `/projects/code/autocoder`

```bash
# Make sure it exists
ls /mnt/e/projects/code/autocoder/

# If not, the scripts will run in limited mode
```

### "HuggingFace models failed to load"

**Solution:** Install dependencies

```bash
pip install transformers torch sentence-transformers
```

### "Out of memory"

**Solution:** Use smaller models or CPU-only

```bash
# Use CPU
python setup_huggingface.py  # Automatically uses CPU if no GPU

# Or use lighter models
export USE_SMALL_MODELS=1
```

---

## 📊 What You Get

### Without Any Setup:
- ✅ Code analysis
- ✅ Issue detection
- ✅ Improvement suggestions
- ✅ Task prioritization

### With AutoCoder:
- ✅ All of the above, plus:
- ✅ Pattern learning
- ✅ Code generation
- ✅ Quality scoring
- ✅ Auto-improvements

### With HuggingFace:
- ✅ All of the above, plus:
- ✅ Advanced code generation
- ✅ Content generation
- ✅ Multi-model ensembles
- ✅ Fine-tuned models

### With Full Setup:
- ✅ Everything!
- ✅ Autonomous development
- ✅ Self-improving system
- ✅ Continuous optimization

---

## 💰 Cost Breakdown

**Free Tier Usage:**
- Groq: Unlimited basic usage (FREE)
- GitHub Models: Unlimited (FREE)
- Gemini: 1M tokens/day (FREE)
- HuggingFace: Free inference (FREE)

**For 1,000 Features:**
- Using FREE APIs: $0
- Using Gemini fallback: $0
- Using DeepSeek: ~$5 (if free tier exhausted)

**Compare to:**
- GPT-4: $500-1,000
- Human developer: $50,000-100,000

**ROI: Infinite (free) to 10,000x** 🚀

---

## 📈 Expected Results

### Week 1:
- Train AI on game code
- Generate 5-10 features
- Fix 3-5 bugs
- Improve code quality

### Week 2:
- Integrate HuggingFace
- Generate 20-30 features
- Add advanced features
- Auto-optimize performance

### Month 1:
- Fully autonomous development
- 100+ features generated
- Continuous improvements
- Self-learning system

---

## 🎯 Next Steps

### Beginner Path:
1. ✅ Run Option 1 demo (see it work)
2. ✅ Set up free API keys
3. ✅ Run train_autocoder.py
4. ✅ Generate first feature

### Intermediate Path:
1. ✅ Complete beginner path
2. ✅ Set up HuggingFace
3. ✅ Run autonomous developer
4. ✅ Deploy to Oracle Cloud (free)

### Advanced Path:
1. ✅ Complete intermediate path
2. ✅ Fine-tune models on Kaggle
3. ✅ Upload custom models to HuggingFace
4. ✅ Build multi-game training pipeline

---

## 📚 Documentation

- **Full Plan**: AI_INTEGRATION_PLAN.md
- **Training**: train_autocoder.py
- **HuggingFace**: setup_huggingface.py
- **Autonomous**: autonomous_game_dev.py

---

## 💡 Pro Tips

1. **Start with FREE APIs** - No credit card needed
2. **Train on your code first** - Better quality
3. **Use multiple models** - Better results
4. **Let it run overnight** - Autonomous learning
5. **Check generated code** - Always verify before deploying

---

## 🎉 You're Ready!

Pick your path and start:

```bash
# Quick demo
python -c "print('🎮 Demo ready!')"

# Or full setup
python train_autocoder.py
```

**Your game will improve itself while you sleep!** 🌙🤖

---

**Questions?** Check AI_INTEGRATION_PLAN.md for detailed explanations.

**Ready to go?** Run the commands above! 🚀
