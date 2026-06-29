# Downloads the local models via Ollama.
# Run:  ./scripts/pull_models.ps1          (core set, ~15 GB)
#       ./scripts/pull_models.ps1 -Extras  (also smaller/faster general models)

param([switch]$Extras)

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "Ollama is not installed. Run:  winget install --id Ollama.Ollama -e" -ForegroundColor Red
    Write-Host "Then open a new terminal and run this script again."
    exit 1
}

function Pull-Model($name) {
    Write-Host ("`n--> pulling {0}" -f $name) -ForegroundColor Cyan
    & ollama pull $name
    if ($LASTEXITCODE -ne 0) {
        Write-Host ("    failed: {0}" -f $name) -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Core set
Pull-Model "qwen2.5-coder:7b"        | Out-Null   # coding (fits your GPU)
Pull-Model "qwen2.5:14b"             | Out-Null   # reasoning / writing
Pull-Model "nomic-embed-text"        | Out-Null   # embeddings for RAG

# Autocomplete model: try the FIM base tag, fall back to the instruct 1.5B.
if (-not (Pull-Model "qwen2.5-coder:1.5b-base")) {
    Write-Host "    base tag unavailable, pulling qwen2.5-coder:1.5b instead" -ForegroundColor Yellow
    Pull-Model "qwen2.5-coder:1.5b" | Out-Null
    Write-Host "    NOTE: update config/continue-config.yaml autocomplete model to qwen2.5-coder:1.5b"
}

if ($Extras) {
    Pull-Model "qwen2.5:7b"   | Out-Null   # faster general model
    Pull-Model "llama3.2:3b"  | Out-Null   # tiny, very fast for quick tasks
}

Write-Host "`nInstalled models:" -ForegroundColor Green
& ollama list
