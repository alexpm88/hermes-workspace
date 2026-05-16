# Hermes Workspace — Windows Installation Script
# Usage: powershell -ExecutionPolicy Bypass -File install-windows.ps1

param(
    [string]$InstallDir = "$env:USERPROFILE\hermes-workspace",
    [string]$GatewayPort = "8642",
    [string]$LMStudioUrl = "http://localhost:1234/v1/chat/completions"
)

# Color output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-ErrorMsg { Write-Host $args -ForegroundColor Red }

# Check prerequisites
function Test-Prerequisite {
    param([string]$Name, [string]$Command, [string]$Url)
    
    try {
        $null = & $Command --version 2>$null
        Write-Success "  [OK] $Name installed"
        return $true
    }
    catch {
        Write-ErrorMsg "  [FAIL] Missing: $Name"
        Write-Warning "    Install from: $Url"
        return $false
    }
}

Write-Info @"

   ╭────────────────────────────────────────────╮
   │  HERMES WORKSPACE — Windows Installer     │
   │  Setup for LM Studio Local LLM              │
   ╰────────────────────────────────────────────╯

"@

Write-Info "=== Checking prerequisites... ==="
$allInstalled = $true
$allInstalled = (Test-Prerequisite "Node.js" "node" "https://nodejs.org/") -and $allInstalled
$allInstalled = (Test-Prerequisite "Git" "git" "https://git-scm.com/") -and $allInstalled
$allInstalled = (Test-Prerequisite "Python" "python" "https://www.python.org/") -and $allInstalled

if (-not $allInstalled) {
    Write-ErrorMsg ""
    Write-ErrorMsg "Please install missing prerequisites and re-run."
    exit 1
}

# Check Node version
$nodeVersion = & node -v
Write-Success "  Node $nodeVersion [OK]"

# Check pnpm
Write-Info "=== Checking pnpm ==="
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Warning "  pnpm not found — installing via corepack…"
    & npm install -g pnpm 2>$null
}
Write-Success "  pnpm $(pnpm --version) [OK]"

# Clone workspace
Write-Info "=== Setting up Hermes Workspace ==="
if (Test-Path "$InstallDir\.git") {
    Write-Warning "  $InstallDir exists — updating…"
    & git -C $InstallDir pull --ff-only
}
elseif (-not (Test-Path $InstallDir)) {
    Write-Info "  Cloning repository…"
    & git clone https://github.com/outsourc-e/hermes-workspace.git $InstallDir
    if ($LASTEXITCODE -ne 0) {
        Write-Error "  Clone failed"
        exit 1
    }
}

# Create .env file
Write-Info "=== Creating .env configuration ==="
$envFile = "$InstallDir\.env"
$envContent = @"
# LM Studio Configuration
# Using local model via LM Studio on port 1234

# Ollama / Local LLM setup (no API key needed)
# Point to LM Studio's OpenAI-compatible endpoint
OLLAMA_API_BASE=$LMStudioUrl

# Hermes Agent Connection
HERMES_API_URL=http://127.0.0.1:$GatewayPort

# Server configuration
PORT=3002
HOST=127.0.0.1

# Workspace session password (optional - set for remote access)
# HERMES_PASSWORD=your-strong-password-here
"@

if (Test-Path $envFile) {
    Write-Warning "  .env already exists — skipping (edit manually if needed)"
} else {
    Set-Content -Path $envFile -Value $envContent
    Write-Success "  Created: $envFile"
}

# Install dependencies
Write-Info "=== Installing Node dependencies ==="
Set-Location $InstallDir
& pnpm install
if ($LASTEXITCODE -ne 0) {
    Write-ErrorMsg "  Installation failed"
    exit 1
}

# Display next steps
Write-Success @"

===================================================
[OK] Installation complete!

NEXT STEPS:

1. Start LM Studio (if not running):
   - Open LM Studio app
   - Select a model (e.g., Qwen 2.5 Coder 3B)
   - Click "Start Server" — runs on http://localhost:1234

2. Start Hermes Workspace:
   From: $InstallDir
   Run:  pnpm dev
   
   Then open http://localhost:3002 in your browser

3. Test LM Studio API:
   $LMStudioUrl

===================================================
"@

Write-Info "Configuration Summary:"
Write-Host "  Workspace:  $InstallDir"
Write-Host "  LM Studio:  $LMStudioUrl"
Write-Host "  Gateway:    http://127.0.0.1:$GatewayPort"
Write-Host ""
