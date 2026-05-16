# LM Studio + Hermes Workspace Setup Guide

**Last Updated**: May 12, 2026

This guide walks through setting up **LM Studio** (local LLM) with the **Hermes Workspace** on Windows.

---

## Prerequisites

- **Windows 10/11** with at least 8GB RAM (16GB+ recommended for large models)
- **LM Studio**: https://lmstudio.ai/
- **Node.js 22+**: https://nodejs.org/
- **Git for Windows**: https://git-scm.com/
- **Python 3.10+**: https://www.python.org/

---

## Part 1: Install LM Studio

### Download & Install
1. Go to https://lmstudio.ai/
2. Download the Windows installer
3. Run the installer and complete setup
4. Launch LM Studio

### Download a Model
LM Studio comes with a built-in model browser:

1. Open LM Studio
2. Click **"Search models"** (magnifying glass on left sidebar)
3. Search for: `qwen2.5-coder-3b` ← **Recommended for coding** (small, fast, capable)
   - Or try: `mistral-7b-instruct` (larger, more capable)
4. Click **Download** and wait for completion

### Start the API Server
1. In LM Studio, go to **Local Server** tab
2. Select your downloaded model from the dropdown
3. Click **"Start Server"** button
4. Wait for: `LM Studio Server listening on http://localhost:1234`

**Keep LM Studio running** — it runs a background HTTP server on port 1234.

---

## Part 2: Install Hermes Workspace on Windows

### Option A: Using the Windows Installer Script (Recommended)

1. Open **PowerShell as Administrator**
2. Run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
   cd "C:\Users\Lenovo\Documents\GitHub\hermes-workspace"
   .\install-windows.ps1
   ```

### Option B: Manual Installation

1. **Install Node.js 22+**
   - Download from https://nodejs.org/
   - Use defaults during install

2. **Install pnpm** (package manager)
   ```powershell
   npm install -g pnpm
   ```

3. **Clone or use existing workspace**
   ```powershell
   cd c:\Users\Lenovo\Documents\GitHub\hermes-workspace
   ```

4. **Install dependencies**
   ```powershell
   pnpm install
   ```

5. **Create `.env` file**
   ```powershell
   copy .env.example .env
   ```

---

## Part 3: Configure for LM Studio

### Edit `.env` File

Open `c:\Users\Lenovo\Documents\GitHub\hermes-workspace\.env` and configure:

```env
# ══════════════════════════════════════════════════════════════
# LM Studio Configuration
# ══════════════════════════════════════════════════════════════

# LM Studio runs on port 1234 with OpenAI-compatible API
# Point any OpenAI/Claude API calls here:
OLLAMA_API_BASE=http://localhost:1234/v1

# OR if using a custom integration:
LM_STUDIO_URL=http://localhost:1234/v1/chat/completions

# ══════════════════════════════════════════════════════════════
# Server Configuration
# ══════════════════════════════════════════════════════════════

# Workspace runs on port 3002
PORT=3002
HOST=127.0.0.1

# Optional: Add password for remote access
# HERMES_PASSWORD=your-strong-32-char-password-here

# ══════════════════════════════════════════════════════════════
# Hermes Agent (optional - for multi-agent support)
# ══════════════════════════════════════════════════════════════

# If running Hermes Agent gateway separately:
# HERMES_API_URL=http://127.0.0.1:8642
```

---

## Part 4: Verify LM Studio API

Test the API before starting Hermes:

### Using curl (Windows PowerShell)

```powershell
$json = @{
    model = "qwen2.5-coder-3b-instruct-abliterated"
    messages = @(
        @{
            role = "system"
            content = "You are a helpful assistant."
        },
        @{
            role = "user"
            content = "What is 2+2?"
        }
    )
    temperature = 0.1
    max_tokens = 50
    stream = $false
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:1234/v1/chat/completions" `
  -Method Post `
  -Headers @{"Content-Type"="application/json"} `
  -Body $json
```

**Expected response:**
```json
{
  "model": "qwen2.5-coder-3b-instruct-abliterated",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "2 + 2 = 4"
      }
    }
  ]
}
```

### Using curl (Git Bash)

```bash
curl http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "messages": [
        {
            "role": "system",
            "content": "You are a helpful assistant."
        },
        {
            "role": "user",
            "content": "What day is it today?"
        }
    ],
    "temperature": 0.1,
    "max_tokens": -1,
    "stream": false
}'
```

---

## Part 5: Start the Workspace

### Terminal 1: Keep LM Studio Running
- ✅ LM Studio Server must stay running on port 1234

### Terminal 2: Start Hermes Workspace

```powershell
cd c:\Users\Lenovo\Documents\GitHub\hermes-workspace
pnpm dev
```

Expected output:
```
VITE v5.x.x build xxx

➜ Local:   http://localhost:3002/
➜ press h + enter to show help
```

### Terminal 3 (Optional): Start Hermes Agent Gateway

If using Hermes Agent for multi-agent capabilities:

```powershell
hermes gateway run
```

---

## Part 6: Access the Workspace

1. **Open browser**: http://localhost:3002
2. **Chat interface** loads with LM Studio backend
3. **Send messages** — they're processed by your local model

### Test Message

```
System: Today is Thursday.
User: What day is it?
```

Expected: Model responds based on LM Studio local inference.

---

## Troubleshooting

### "Connection refused on port 1234"
- ❌ LM Studio not running
- ✅ Start LM Studio and click "Start Server"

### "Model not found"
- ❌ No model downloaded in LM Studio
- ✅ In LM Studio, go to Search → download `qwen2.5-coder-3b`

### "pnpm: command not found"
- ❌ pnpm not installed globally
- ✅ Run: `npm install -g pnpm`

### "Port 3002 already in use"
- ❌ Another app is using the port
- ✅ Change in `.env`: `PORT=3003` and retry

### Workspace can't reach LM Studio
- ❌ Wrong URL in `.env`
- ✅ Verify `OLLAMA_API_BASE=http://localhost:1234/v1`
- ✅ Test API manually first (curl test above)

---

## Model Recommendations

| Model | Size | Speed | Capability | Best For |
|-------|------|-------|-----------|----------|
| **Qwen 2.5 Coder 3B** | ~2GB | ⚡ Fast | 🟡 Good | Coding, lightweight |
| **Mistral 7B Instruct** | ~5GB | 🟢 Normal | 🟢 Very Good | General chat, reasoning |
| **Neural Chat 7B** | ~5GB | 🟢 Normal | 🟢 Very Good | Chat-optimized |
| **Llama 2 70B** | ~40GB | 🐢 Slow | 🟢🟢 Excellent | Advanced reasoning (GPU only) |

**Recommended for Windows**: Qwen 2.5 Coder 3B or Mistral 7B

---

## Advanced: Custom Model Loading

If you want to use a specific model with custom parameters:

### Edit `.env`
```env
# Custom model name (must match what you loaded in LM Studio)
LM_STUDIO_MODEL=your-model-name-here

# Override default temperature (0.1 = deterministic, 1.0 = creative)
LM_STUDIO_TEMPERATURE=0.1

# Max tokens per response (-1 = unlimited)
LM_STUDIO_MAX_TOKENS=-1
```

---

## Performance Tips

1. **Use smaller models** if your PC has <16GB RAM
2. **Close other apps** while using the workspace
3. **GPU acceleration**: LM Studio auto-detects NVIDIA/AMD GPUs
4. **Disable debug logs**: Set `DEBUG=` in `.env` to reduce overhead

---

## Next Steps

- 📚 **Learn Hermes**: https://github.com/outsourc-e/hermes-workspace
- 🤖 **Explore models**: https://lmstudio.ai/ or https://ollama.ai/
- 🔧 **Customize workspace**: Edit `src/` files as needed
- 💾 **Save sessions**: The workspace auto-saves chat history

---

**Questions?** Open an issue: https://github.com/outsourc-e/hermes-workspace/issues
