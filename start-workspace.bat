@echo off
REM Hermes Workspace — Quick Start Script for Windows
REM This script starts both LM Studio test and Hermes Workspace

setlocal enabledelayedexpansion

cls
echo.
echo   ╔════════════════════════════════════════════════════════════╗
echo   ║    HERMES WORKSPACE + LM STUDIO — Quick Start              ║
echo   ║    Setup complete? Follow these steps:                     ║
echo   ╚════════════════════════════════════════════════════════════╝
echo.

echo 📋 SETUP CHECKLIST:
echo   ☐ 1. LM Studio downloaded from https://lmstudio.ai
echo   ☐ 2. Model downloaded in LM Studio (e.g., Qwen 2.5 Coder 3B)
echo   ☐ 3. Node.js 22+ installed from https://nodejs.org
echo.

echo 🚀 STARTING SERVICES:
echo.
echo   Step 1: Start LM Studio
echo   ──────────────────────────────────────
echo   ✓ Open LM Studio app
echo   ✓ Click "Local Server" tab
echo   ✓ Select model from dropdown
echo   ✓ Click "Start Server"
echo   ✓ Wait for: "LM Studio listening on http://localhost:1234"
echo.
echo   Press ENTER when LM Studio server is running...
pause

echo.
echo   Step 2: Test LM Studio API
echo   ──────────────────────────────────────
powershell -NoProfile -ExecutionPolicy Bypass -File "test-lm-studio.ps1"

if errorlevel 1 (
    echo.
    echo ❌ LM Studio API test failed. Please check:
    echo    - LM Studio is running
    echo    - "Start Server" is clicked
    echo    - A model is selected
    pause
    exit /b 1
)

echo.
echo   Step 3: Install dependencies (first time only)
echo   ──────────────────────────────────────
if not exist "node_modules" (
    echo Installing pnpm dependencies...
    call pnpm install
) else (
    echo Dependencies already installed ✓
)

echo.
echo   Step 4: Start Hermes Workspace
echo   ──────────────────────────────────────
echo Starting on http://localhost:3002
echo.

call pnpm dev

pause
