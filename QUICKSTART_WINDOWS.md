# ⚡ Hermes Workspace + LM Studio — Windows Setup Quick Start

> **Goal**: Run Hermes Workspace with a local AI model (LM Studio) on your Windows PC  
> **Time**: ~15 minutes  
> **Requirements**: 8GB+ RAM, stable internet (for downloading model)

---

## 📦 What You're Installing

| Component | Purpose | Port |
|-----------|---------|------|
| **LM Studio** | Local LLM interface (AI model runner) | 1234 |
| **Node.js** | Runtime for Hermes Workspace | - |
| **Hermes Workspace** | Chat UI + agent orchestration | 3002 |

---

## 🚀 Quick Start (5 Minutes)

### **Step 1: Download & Install Prerequisites**

Open **PowerShell as Administrator** and run:

```powershell
# Install chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Node.js, Git, and Python
choco install nodejs git python -y
```

**OR manually install:**
- Node.js 22+ → https://nodejs.org/ (choose LTS)
- Git → https://git-scm.com/
- Python 3.10+ → https://www.python.org/

### **Step 2: Get LM Studio**

1. Download from: https://lmstudio.ai/
2. Install using the Windows installer
3. Launch LM Studio

### **Step 3: Download a Model in LM Studio**

Inside LM Studio:
1. Click **"Search models"** (magnifying glass, left sidebar)
2. Search: `qwen2.5-coder-3b`
3. Click **Download** (wait 2-5 minutes)
4. Once done, click **Local Server** tab
5. Select model from dropdown
6. Click **"Start Server"**

**Wait for**: `LM Studio Server listening on http://localhost:1234`

✅ **Keep this running in background**

---

### **Step 4: Set Up Hermes Workspace**

Open **new PowerShell window** and run:

```powershell
cd c:\Users\Lenovo\Documents\GitHub\hermes-workspace

# Install global pnpm (if needed)
npm install -g pnpm

# Run Windows installer
.\install-windows.ps1
```

This will:
- ✓ Check prerequisites
- ✓ Install Node dependencies
- ✓ Create `.env` file

### **Step 5: Start Hermes Workspace**

```powershell
cd c:\Users\Lenovo\Documents\GitHub\hermes-workspace
pnpm dev
```

Wait for: `Local:   http://localhost:3002/`

### **Step 6: Open in Browser**

Navigate to: **http://localhost:3002**

🎉 **You're done!** Start chatting with your local LM Studio model.

---

## 📋 Architecture Diagram

```
Your Browser
    ↓
Hermes Workspace (http://localhost:3002)
    ↓
LM Studio API (http://localhost:1234/v1/chat/completions)
    ↓
Local Model (e.g., Qwen 2.5 Coder 3B)
    ↓
GPU or CPU (inference)
```

---

## 🧪 Verify Everything Works

After starting both services, test the connection:

```powershell
# Test LM Studio API directly
curl.exe http://localhost:1234/v1/chat/completions `
  -H "Content-Type: application/json" `
  -d '{
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "messages": [{"role": "user", "content": "Hello"}],
    "temperature": 0.1,
    "max_tokens": 50,
    "stream": false
}'
```

**Expected response**: JSON with model's reply

Or use the provided test script:
```powershell
.\test-lm-studio.ps1
```

---

## 📁 Project Structure

```
hermes-workspace/
├── install-windows.ps1      ← Run to install
├── start-workspace.bat      ← Easy start (double-click)
├── test-lm-studio.ps1       ← Test API connection
├── .env                     ← Configuration (created by installer)
├── .env.lm-studio          ← Preconfigured for LM Studio
├── SETUP_LM_STUDIO_WINDOWS.md  ← Full setup guide
├── src/                     ← React app source
├── package.json            ← Dependencies
└── dist/                    ← Built app (after `pnpm build`)
```

---

## 🎛️ Configuration Files

### `.env` (Auto-created by installer)
```env
OLLAMA_API_BASE=http://localhost:1234/v1
PORT=3002
HOST=127.0.0.1
```

### Or copy from `.env.lm-studio`:
```bash
cp .env.lm-studio .env
```

---

## 🔧 Common Commands

| Command | Purpose |
|---------|---------|
| `pnpm dev` | Start workspace in dev mode (http://localhost:3002) |
| `pnpm build` | Build for production |
| `pnpm lint` | Check code style |
| `.\test-lm-studio.ps1` | Verify LM Studio is working |
| `.\start-workspace.bat` | All-in-one start script |

---

## 🆘 Troubleshooting

### ❌ "Cannot reach http://localhost:1234"
**Solution:**
- Open LM Studio app
- Click **"Local Server"** tab
- Select model from dropdown
- Click **"Start Server"**
- Wait for: "listening on http://localhost:1234"

### ❌ "Model not found / Download failed"
**Solution:**
- In LM Studio → **Search models**
- Try a different model: `mistral-7b-instruct` or `neural-chat-7b-v3-1`
- Check internet connection

### ❌ "Port 3002 already in use"
**Solution:**
- Edit `.env`: change `PORT=3002` to `PORT=3003`
- Restart: `pnpm dev`

### ❌ "pnpm: command not found"
**Solution:**
- Install globally: `npm install -g pnpm`

### ❌ "Node version too old"
**Solution:**
- Uninstall Node.js completely
- Download & install Node 22 LTS from https://nodejs.org/

---

## 📊 Model Recommendations

| Model | Download | RAM | Speed | Capability |
|-------|----------|-----|-------|-----------|
| **Qwen 2.5 Coder 3B** | ~2GB | 4GB | ⚡ Fast | Good coding |
| **Mistral 7B** | ~5GB | 8GB | Normal | Very good |
| **Neural Chat 7B** | ~5GB | 8GB | Normal | Very good |
| **Llama 2 13B** | ~8GB | 12GB | Slower | Excellent |

**Best for beginners**: Qwen 2.5 Coder 3B (fast, small)

---

## 💡 Tips & Tricks

1. **More powerful models** = slower but smarter responses
2. **GPU acceleration**: LM Studio auto-detects NVIDIA/AMD GPUs (much faster!)
3. **Keep LM Studio running** as a background service
4. **First response is slower** (model loads to VRAM)
5. **Use temperature=0.1** for deterministic/coding tasks
6. **Use temperature=0.7** for creative writing

---

## 📚 Next Steps

- 🔗 **Explore settings** in Hermes Workspace UI
- 📖 **Read full guide**: [SETUP_LM_STUDIO_WINDOWS.md](./SETUP_LM_STUDIO_WINDOWS.md)
- 🤖 **Try different models**: https://lmstudio.ai/
- 💾 **Save chat sessions** (auto-saved in ~/.hermes/)
- 🔌 **Add more skills**: https://github.com/outsourc-e/hermes-workspace

---

## 🎓 How It Works

```
1. You type in Hermes UI (browser)
   ↓
2. Sent to workspace server (Node.js on :3002)
   ↓
3. Forwarded to LM Studio API (http://localhost:1234)
   ↓
4. Model runs inference locally
   ↓
5. Response streams back to browser
   ↓
6. Displayed in chat interface
```

**No cloud calls.** Everything runs locally on your PC. ✨

---

## 📞 Support

- **Hermes Issues**: https://github.com/outsourc-e/hermes-workspace/issues
- **LM Studio Help**: https://lmstudio.ai/docs
- **Models**: https://huggingface.co/models

---

**Happy coding! 🚀**
