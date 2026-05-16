@echo off
REM Hermes Workspace + LM Studio Installation Script for Windows
REM Simple batch installer

setlocal enabledelayedexpansion

cls
echo.
echo ====================================================
echo   HERMES WORKSPACE + LM STUDIO INSTALLER
echo   Windows Setup
echo ====================================================
echo.

REM Check if we're in the right directory
if not exist "package.json" (
    echo ERROR: Please run this from the hermes-workspace directory
    pause
    exit /b 1
)

echo [1/5] Checking prerequisites...
where node >nul 2>nul
if errorlevel 1 (
    echo ERROR: Node.js not found
    echo Please install Node.js 22+ from https://nodejs.org/
    pause
    exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
    echo ERROR: Git not found
    echo Please install Git from https://git-scm.com/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
echo   Node.js: %NODE_VER% [OK]

echo.
echo [2/5] Installing pnpm...
npm install -g pnpm >nul 2>nul
if errorlevel 1 (
    echo WARNING: Could not install pnpm globally, using npm instead
) else (
    for /f "tokens=*" %%i in ('pnpm --version') do set PNPM_VER=%%i
    echo   pnpm: !PNPM_VER! [OK]
)

echo.
echo [3/5] Creating .env file...
if exist ".env" (
    echo   .env already exists - skipping
) else (
    (
        echo # LM Studio Configuration
        echo OLLAMA_API_BASE=http://localhost:1234/v1
        echo.
        echo # Hermes Agent Connection
        echo HERMES_API_URL=http://127.0.0.1:8642
        echo.
        echo # Server configuration
        echo PORT=3002
        echo HOST=127.0.0.1
    ) > .env
    echo   Created .env [OK]
)

echo.
echo [4/5] Installing dependencies (this may take 2-5 minutes)...
echo   Running: pnpm install
call pnpm install
if errorlevel 1 (
    echo.
    echo ERROR: pnpm install failed
    pause
    exit /b 1
)

echo.
echo [5/5] Installation complete!
echo.
echo ====================================================
echo   NEXT STEPS:
echo ====================================================
echo.
echo 1. Start LM Studio:
echo    - Open LM Studio app from https://lmstudio.ai/
echo    - Download a model (e.g., qwen2.5-coder-3b)
echo    - Click "Local Server" tab
echo    - Click "Start Server"
echo    - Wait for: "LM Studio listening on http://localhost:1234"
echo.
echo 2. Start Hermes Workspace:
echo    Run: pnpm dev
echo.
echo 3. Open in browser:
echo    http://localhost:3002
echo.
echo ====================================================
echo.
pause
