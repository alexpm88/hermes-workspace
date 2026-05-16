#!/usr/bin/env powershell
# Test LM Studio API connection
# Usage: pwsh -NoProfile -ExecutionPolicy Bypass test-lm-studio.ps1

param(
    [string]$Url = "http://localhost:1234/v1/chat/completions",
    [string]$Model = "qwen2.5-coder-3b-instruct-abliterated"
)

Write-Host @"
╭─────────────────────────────────────────────╮
│  LM Studio API Connection Test              │
│  Testing: $Url            │
╰─────────────────────────────────────────────╯
"@ -ForegroundColor Cyan

# Test 1: Check if server is reachable
Write-Host ""
Write-Host "1️⃣  Testing connectivity..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $Url -Method Options -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   ✓ Server is reachable" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Cannot reach $Url" -ForegroundColor Red
    Write-Host "   Make sure LM Studio is running and 'Start Server' is clicked" -ForegroundColor Red
    exit 1
}

# Test 2: Send a simple prompt
Write-Host ""
Write-Host "2️⃣  Testing API with simple prompt..." -ForegroundColor Yellow

$testPayload = @{
    model = $Model
    messages = @(
        @{
            role = "user"
            content = "Say 'Hello from LM Studio!' and nothing else."
        }
    )
    temperature = 0.1
    max_tokens = 50
    stream = $false
} | ConvertTo-Json -Depth 10

try {
    $apiResponse = Invoke-WebRequest `
        -Uri $Url `
        -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $testPayload `
        -TimeoutSec 30 `
        -ErrorAction Stop
    
    $json = $apiResponse.Content | ConvertFrom-Json
    $message = $json.choices[0].message.content
    
    Write-Host "   ✓ API responded successfully" -ForegroundColor Green
    Write-Host "   Model: $Model" -ForegroundColor Gray
    Write-Host "   Response: $message" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ API request failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Verify model name
Write-Host ""
Write-Host "3️⃣  Verifying model name..." -ForegroundColor Yellow

$modelPayload = @{
    model = $Model
    messages = @(
        @{
            role = "user"
            content = "Hi"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $modelResponse = Invoke-WebRequest `
        -Uri $Url `
        -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $modelPayload `
        -TimeoutSec 30 `
        -ErrorAction Stop
    
    $modelJson = $modelResponse.Content | ConvertFrom-Json
    $returnedModel = $modelJson.model
    
    Write-Host "   ✓ Model loaded: $returnedModel" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Could not verify model (but API works)" -ForegroundColor Yellow
}

# Test 4: Test streaming
Write-Host ""
Write-Host "4️⃣  Testing streaming..." -ForegroundColor Yellow

$streamPayload = @{
    model = $Model
    messages = @(
        @{
            role = "user"
            content = "Count to 3"
        }
    )
    stream = $true
} | ConvertTo-Json -Depth 10

try {
    $streamResponse = Invoke-WebRequest `
        -Uri $Url `
        -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $streamPayload `
        -TimeoutSec 30 `
        -ErrorAction Stop
    
    Write-Host "   ✓ Streaming works" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Streaming may not be available" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "═════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ LM Studio API is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start Hermes Workspace:  pnpm dev" -ForegroundColor Gray
Write-Host "  2. Open:                    http://localhost:3002" -ForegroundColor Gray
Write-Host "  3. Begin chatting!          (requests go to LM Studio)" -ForegroundColor Gray
Write-Host ""
Write-Host "Configuration in .env:" -ForegroundColor Cyan
Write-Host "  OLLAMA_API_BASE=http://localhost:1234/v1" -ForegroundColor Gray
Write-Host ""
