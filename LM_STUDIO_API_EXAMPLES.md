# LM Studio API Testing — Windows Examples

This document shows how to test the LM Studio API on Windows using different tools.

---

## Prerequisites

- **LM Studio running** on http://localhost:1234
- **Server started** (click "Start Server" in LM Studio)
- A **model downloaded** (e.g., `qwen2.5-coder-3b-instruct-abliterated`)

---

## Method 1: PowerShell (Recommended)

### Simple Test

```powershell
$json = @{
    model = "qwen2.5-coder-3b-instruct-abliterated"
    messages = @(
        @{ role = "system"; content = "Always answer in rhymes. Today is Thursday" },
        @{ role = "user"; content = "What day is it today?" }
    )
    temperature = 0.1
    max_tokens = -1
    stream = $false
} | ConvertTo-Json -Depth 10

Invoke-WebRequest -Uri "http://localhost:1234/v1/chat/completions" `
  -Method Post `
  -Headers @{"Content-Type" = "application/json"} `
  -Body $json
```

### Pretty Print Response

```powershell
$json = @{
    model = "qwen2.5-coder-3b-instruct-abliterated"
    messages = @(
        @{ role = "user"; content = "Say 'Hello from LM Studio!'" }
    )
    temperature = 0.1
    max_tokens = 50
    stream = $false
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:1234/v1/chat/completions" `
  -Method Post `
  -Headers @{"Content-Type" = "application/json"} `
  -Body $json

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### Save to File

```powershell
$json = @{
    model = "qwen2.5-coder-3b-instruct-abliterated"
    messages = @(@{ role = "user"; content = "Generate 3 random names" })
    temperature = 0.7
    max_tokens = 100
    stream = $false
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:1234/v1/chat/completions" `
  -Method Post `
  -Headers @{"Content-Type" = "application/json"} `
  -Body $json

$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Out-File "response.json"
Write-Host "Response saved to response.json"
```

---

## Method 2: curl (Git Bash)

### Simple Test

```bash
curl http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "messages": [
        {
            "role": "system",
            "content": "Always answer in rhymes. Today is Thursday"
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

### Pretty Print with jq

```bash
curl -s http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "messages": [
        {"role": "user", "content": "Hello"}
    ]
  }' | jq '.'
```

### Save to File

```bash
curl -s http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "messages": [
        {"role": "user", "content": "Generate 3 random names"}
    ]
  }' > response.json

cat response.json
```

---

## Method 3: Windows cmd (curl.exe native)

### Simple Test

```cmd
curl http://localhost:1234/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -d "{\"model\":\"qwen2.5-coder-3b-instruct-abliterated\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}"
```

### With File (recommended for complex JSON)

Create `request.json`:
```json
{
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "messages": [
        {
            "role": "system",
            "content": "You are a helpful assistant."
        },
        {
            "role": "user",
            "content": "What is 2+2?"
        }
    ],
    "temperature": 0.1,
    "max_tokens": 50,
    "stream": false
}
```

Then run:
```cmd
curl http://localhost:1234/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -d @request.json
```

---

## Method 4: Invoke-RestMethod (PowerShell)

```powershell
$response = Invoke-RestMethod `
    -Uri "http://localhost:1234/v1/chat/completions" `
    -Method Post `
    -ContentType "application/json" `
    -Body (@{
        model = "qwen2.5-coder-3b-instruct-abliterated"
        messages = @(@{ role = "user"; content = "What is the capital of France?" })
        temperature = 0.1
    } | ConvertTo-Json)

$response.choices[0].message.content
```

---

## Common API Parameters

| Parameter | Type | Example | Notes |
|-----------|------|---------|-------|
| `model` | string | `"qwen2.5-coder-3b-instruct-abliterated"` | Must match LM Studio's model |
| `messages` | array | `[{"role": "user", "content": "..."}]` | Conversation history |
| `temperature` | float | `0.1` | 0=deterministic, 1.0=creative |
| `max_tokens` | int | `-1` | -1=unlimited, positive=token limit |
| `stream` | boolean | `false` | `true`=streaming, `false`=complete response |
| `top_p` | float | `0.95` | Nucleus sampling parameter |

---

## Expected Response Format

```json
{
    "id": "chatcmpl-...",
    "object": "chat.completion",
    "created": 1234567890,
    "model": "qwen2.5-coder-3b-instruct-abliterated",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "The capital of France is Paris."
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 10,
        "completion_tokens": 8,
        "total_tokens": 18
    }
}
```

---

## Troubleshooting

### "Connection refused"
```powershell
# Check if LM Studio is listening
Test-NetConnection -ComputerName localhost -Port 1234
```

### "Model not found"
- Verify model name matches exactly in LM Studio
- Check LM Studio "Local Server" tab for loaded model name

### "Empty response"
- Model may be unloaded → restart LM Studio server
- Check LM Studio logs for errors

### "Timeout"
- Model inference is slow (first response especially)
- Reduce `max_tokens` or wait longer

---

## Batch Script Example

Create `test-lm-studio.bat`:

```batch
@echo off
setlocal

set MODEL=qwen2.5-coder-3b-instruct-abliterated
set URL=http://localhost:1234/v1/chat/completions

echo Testing LM Studio API...
echo URL: %URL%
echo Model: %MODEL%
echo.

curl %URL% ^
  -H "Content-Type: application/json" ^
  -d "{\"model\":\"%MODEL%\",\"messages\":[{\"role\":\"user\",\"content\":\"Say hello\"}]}"

pause
```

Run: `test-lm-studio.bat`

---

## Integration with Hermes Workspace

The workspace automatically sends requests to the configured endpoint:

```env
# In .env:
OLLAMA_API_BASE=http://localhost:1234/v1
```

All chat messages go through this endpoint to your local model. ✨

---

## More Information

- **LM Studio Docs**: https://lmstudio.ai/docs
- **OpenAI API Spec**: https://platform.openai.com/docs/api-reference/chat/create
- **Models**: https://huggingface.co/models
