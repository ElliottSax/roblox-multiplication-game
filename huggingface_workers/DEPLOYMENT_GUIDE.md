# 🚀 HuggingFace Workers Deployment Guide

Step-by-step guide to deploy FREE 24/7 autonomous workers for your Roblox game.

---

## 📋 Prerequisites (5 minutes)

### 1. HuggingFace Account
- Go to https://huggingface.co/join
- Sign up (FREE, no credit card)
- Verify email

### 2. GitHub Account
- Make sure you have a GitHub account
- Your game code should be in a repo (or create one)

### 3. GitHub Token
- Go to https://github.com/settings/tokens
- Click "Generate new token (classic)"
- Select scopes: `repo`, `workflow`
- Copy token (save it securely!)

---

## 🚀 Quick Deploy (10 Minutes)

### Method 1: Web Interface (Easiest)

#### Step 1: Create Space (2 min)

1. Go to https://huggingface.co/new-space
2. Fill in details:
   - **Owner:** Your username
   - **Space name:** `roblox-game-worker`
   - **License:** MIT
   - **SDK:** Gradio
   - **Visibility:** Public (or Private)
3. Click **Create Space**

#### Step 2: Upload Files (3 min)

Click "Files" tab → "Add file" → Upload these files:
- ✅ `app.py`
- ✅ `requirements.txt`
- ✅ `README.md`

Or drag & drop the entire folder!

#### Step 3: Configure Secrets (2 min)

Click "Settings" → "Repository secrets" → Add:

```bash
GITHUB_TOKEN=ghp_your_token_here
REPO_URL=https://github.com/your-username/your-repo
WORKER_MODE=feature_generator
```

#### Step 4: Wait for Build (3 min)

Space will automatically:
- Install dependencies
- Start application
- Show web interface

#### Step 5: Start Worker! (1 min)

1. Open your Space URL
2. Select worker mode
3. Click "▶️ Start Worker"
4. Watch it work! 🎉

---

### Method 2: Git CLI (For Developers)

```bash
# Clone your HuggingFace Space
git clone https://huggingface.co/spaces/YOUR-USERNAME/roblox-game-worker
cd roblox-game-worker

# Copy worker files
cp /path/to/multiplication-game/huggingface_workers/* .

# Add files
git add .
git commit -m "Deploy Roblox game worker"

# Push to HuggingFace
git push
```

---

## 🎯 Configure Workers

### Single Worker Setup

**Basic Configuration** (in Space secrets):
```bash
WORKER_MODE=feature_generator
GITHUB_TOKEN=ghp_your_token
REPO_URL=https://github.com/you/your-repo
```

**Worker will:**
- Process tasks from `tasks.json` in your repo
- Generate features automatically
- Create pull requests
- Run 24/7 for FREE

---

### Multiple Workers Setup (Recommended)

Deploy 4 workers for parallel processing:

#### Worker 1: Feature Generator
- **Space:** `roblox-game-features`
- **Mode:** `feature_generator`
- **Purpose:** Generate new game features

#### Worker 2: Bug Fixer
- **Space:** `roblox-game-bugfix`
- **Mode:** `bug_fixer`
- **Purpose:** Fix bugs automatically

#### Worker 3: Code Optimizer
- **Space:** `roblox-game-optimizer`
- **Mode:** `optimizer`
- **Purpose:** Optimize performance

#### Worker 4: Content Creator
- **Space:** `roblox-game-content`
- **Mode:** `content_creator`
- **Purpose:** Generate game content

**Each worker runs in parallel, processing different task types!**

---

## 📝 Create Task Queue

### Method 1: GitHub Repo (Recommended)

Create `tasks.json` in your GitHub repo:

```json
[
  {
    "type": "feature",
    "description": "Add Phoenix object worth 150 currency with fire trail",
    "priority": "high",
    "assigned_to": "feature_generator"
  },
  {
    "type": "bug_fix",
    "file": "CurrencyService.lua",
    "issue": "Missing error handling in AddCurrency",
    "priority": "urgent",
    "assigned_to": "bug_fixer"
  },
  {
    "type": "optimization",
    "file": "ObjectManager.lua",
    "target": "CloneObject function",
    "goal": "Reduce memory usage",
    "priority": "medium",
    "assigned_to": "optimizer"
  },
  {
    "type": "content",
    "content_type": "npc_dialogue",
    "context": "Shop keeper greeting player",
    "priority": "low",
    "assigned_to": "content_creator"
  }
]
```

### Method 2: Space Interface

Or use the web interface:
1. Open your Space
2. Add tasks via the UI
3. Workers process automatically

---

## 🔧 Advanced Configuration

### Custom Model Configuration

Create `worker_config.yaml`:

```yaml
# Worker Configuration
worker:
  mode: feature_generator
  check_interval: 300  # seconds
  batch_size: 5

# Model Configuration
models:
  code_generation:
    name: "Salesforce/codegen-350M-mono"
    device: "cpu"
    max_length: 500

# GitHub Integration
github:
  create_prs: true
  pr_branch_prefix: "ai-generated/"
  auto_assign_reviewers: true

# Task Processing
processing:
  max_retries: 3
  timeout: 600
  parallel_tasks: 1
```

### Environment Variables

All available environment variables:

```bash
# Required
GITHUB_TOKEN=ghp_your_token
REPO_URL=https://github.com/you/repo

# Worker Configuration
WORKER_MODE=feature_generator          # or bug_fixer, optimizer, content_creator
CHECK_INTERVAL=300                     # seconds between checks
BATCH_SIZE=5                           # tasks to process per batch

# Model Configuration
MODEL_NAME=Salesforce/codegen-350M-mono
MODEL_DEVICE=cpu                       # or cuda for GPU
MAX_LENGTH=500                         # max tokens to generate

# GitHub Options
CREATE_PRS=true                        # create pull requests
PR_BRANCH_PREFIX=ai-generated/         # prefix for PR branches
AUTO_MERGE=false                       # auto-merge PRs (dangerous!)

# Logging
LOG_LEVEL=INFO                         # DEBUG, INFO, WARNING, ERROR
LOG_FILE=worker.log
```

---

## 📊 Monitoring

### View Worker Status

**In Space Interface:**
- Real-time status updates
- Tasks processed count
- Success/failure rate
- Recent activity log

**In GitHub:**
- Pull requests from worker
- Code reviews
- Merge history

### Logs

**View logs in HuggingFace Space:**
1. Click "Logs" tab
2. See real-time worker activity
3. Debug any issues

**Download logs:**
```bash
# From your Space repo
git pull
cat worker.log
```

---

## 🐛 Troubleshooting

### Worker Not Starting

**Check:**
1. ✅ Dependencies installed? (Check Space logs)
2. ✅ Secrets configured? (GITHUB_TOKEN, REPO_URL)
3. ✅ Valid GitHub token?
4. ✅ Repo accessible?

**Fix:**
```bash
# Rebuild Space
git commit --allow-empty -m "Rebuild"
git push
```

### No Tasks Processing

**Check:**
1. ✅ `tasks.json` exists in repo?
2. ✅ Tasks have correct format?
3. ✅ Worker mode matches task type?

**Fix:**
```bash
# Add test task
echo '[{"type":"feature","description":"Test task"}]' > tasks.json
git add tasks.json
git commit -m "Add test task"
git push
```

### Pull Requests Not Created

**Check:**
1. ✅ GITHUB_TOKEN has `repo` scope?
2. ✅ REPO_URL correct?
3. ✅ CREATE_PRS=true in settings?

**Fix:**
```bash
# Generate new token with correct scopes
# Update Space secret
```

### Models Not Loading

**Check:**
1. ✅ Sufficient memory? (upgrade Space to GPU if needed)
2. ✅ Correct model name?
3. ✅ Dependencies installed?

**Fix:**
```bash
# Use smaller model
MODEL_NAME=Salesforce/codegen-350M-mono

# Or upgrade to GPU Space (still FREE!)
# Settings → Hardware → GPU
```

---

## 💰 Cost Optimization

### Stay on FREE Tier

**HuggingFace Free Tier Limits:**
- ✅ CPU: 2 cores, 16GB RAM (unlimited)
- ✅ Persistent storage (unlimited)
- ✅ 24/7 uptime (unlimited)
- ✅ **Cost: $0 FOREVER**

**To stay free:**
1. Use CPU-based models (no GPU needed)
2. Use smaller models (350M-1B parameters)
3. Batch process tasks
4. Optimize check intervals

### Scale Up (Still FREE!)

**If you need more power:**
1. Use **Community GPU** (FREE, limited hours)
2. Deploy multiple workers (FREE)
3. Use persistent storage (FREE)

---

## 🎯 Best Practices

### 1. Task Priority
```json
{
  "priority": "urgent",   // < 10 min
  "priority": "high",     // < 1 hour
  "priority": "medium",   // < 6 hours
  "priority": "low"       // When idle
}
```

### 2. Multiple Workers
- Deploy 4 workers (one per task type)
- Parallel processing = 4x speed
- Still 100% FREE!

### 3. Review PRs
- Always review generated code
- Provide feedback in PR comments
- Worker learns from your reviews

### 4. Gradual Rollout
- Start with 1 worker
- Add tasks slowly
- Scale up as confidence grows

---

## 📈 Scaling Strategy

### Week 1: Single Worker
- Deploy feature generator
- Process 5-10 tasks
- Review all PRs carefully

### Week 2: Multiple Workers
- Add bug fixer
- Add optimizer
- Process 20-30 tasks/day

### Month 1: Full Automation
- Deploy all 4 workers
- Process 50-100 tasks/day
- Auto-merge low-risk PRs

### Month 3: Enterprise Scale
- Fine-tune custom models
- 200+ tasks/day
- Fully autonomous development

---

## 🎉 Success Checklist

- [ ] HuggingFace account created
- [ ] Space deployed
- [ ] Secrets configured
- [ ] Worker started
- [ ] Tasks added to queue
- [ ] First PR created
- [ ] Code reviewed and merged
- [ ] Worker learned from feedback

---

## 🚀 You're Done!

Your autonomous worker is now:
- ✅ Running 24/7 on HuggingFace
- ✅ Processing tasks automatically
- ✅ Generating code continuously
- ✅ Creating pull requests
- ✅ Learning and improving

**Cost: $0 | Value: Unlimited**

---

## 📚 Next Steps

1. **Monitor:** Check Space dashboard
2. **Review:** Merge good PRs
3. **Scale:** Deploy more workers
4. **Optimize:** Fine-tune configuration
5. **Celebrate:** You have free AI developers! 🎉

---

**Questions?** Check the README.md or Space logs!

**Ready to scale?** Deploy worker 2, 3, and 4! 🚀
