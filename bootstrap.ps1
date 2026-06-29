# bootstrap.ps1 - one-command setup for icz_local_ai
#
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned   # once
#   ./bootstrap.ps1
#
# Idempotent: safe to re-run. It installs Ollama, pulls models, builds the custom
# assistants, installs the VS Code extensions, copies the Continue config, and verifies.
# It does NOT install the two desktop apps (AnythingLLM, LTeX+); those steps are printed
# at the end and documented in docs/02-installation.md.

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$config = Join-Path $root "config"

function Section($t) { Write-Host "`n==== $t ====" -ForegroundColor Cyan }
function Good($t)    { Write-Host "[ ok ] $t" -ForegroundColor Green }
function Warn($t)    { Write-Host "[warn] $t" -ForegroundColor Yellow }
function Info($t)    { Write-Host "       $t" }

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Ensure-Server {
    for ($i=0; $i -lt 25; $i++) {
        try { Invoke-RestMethod "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction Stop | Out-Null; return $true }
        catch {
            if ($i -eq 0) {
                $app = Join-Path $env:LOCALAPPDATA "Programs\Ollama\ollama app.exe"
                if (Test-Path $app) { Start-Process $app }
            }
            Start-Sleep -Seconds 1
        }
    }
    return $false
}

function Pull-Retry($name, $tries=4) {
    for ($t=1; $t -le $tries; $t++) {
        Info ("pull {0} (attempt {1}/{2})" -f $name, $t, $tries)
        ollama pull $name
        if ($LASTEXITCODE -eq 0) { Good $name; return $true }
        Start-Sleep -Seconds 5; Ensure-Server | Out-Null
    }
    Warn ("could not pull {0}" -f $name); return $false
}

Write-Host "icz_local_ai bootstrap" -ForegroundColor White

# 1. Ollama -------------------------------------------------------------------
Section "1/6  Ollama engine"
Refresh-Path
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    Good ("Ollama present ({0})" -f ((ollama --version) -join ' '))
} else {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw "winget not found; install Ollama manually from https://ollama.com" }
    Info "installing Ollama via winget..."
    winget install --id Ollama.Ollama -e --accept-package-agreements --accept-source-agreements
    Refresh-Path
    if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { throw "Ollama install did not put 'ollama' on PATH; open a new terminal and re-run." }
    Good "Ollama installed"
}
if (Ensure-Server) { Good "server answering on :11434" } else { throw "Ollama server did not start; open Ollama from the Start menu and re-run." }

# 2. Models -------------------------------------------------------------------
Section "2/6  Models (this is the slow part)"
Pull-Retry "qwen2.5-coder:7b" | Out-Null
Pull-Retry "qwen2.5:14b"      | Out-Null
Pull-Retry "nomic-embed-text" | Out-Null
if (-not (Pull-Retry "qwen2.5-coder:1.5b-base" 2)) { Pull-Retry "qwen2.5-coder:1.5b" | Out-Null }

# 3. Assistants ---------------------------------------------------------------
Section "3/6  Custom assistants"
foreach ($a in @(@("nacho-writer","Modelfile.writer"), @("nacho-coder","Modelfile.coder"))) {
    $mf = Join-Path $config $a[1]
    if (Test-Path $mf) {
        ollama create $a[0] -f $mf | Out-Null
        if ($LASTEXITCODE -eq 0) { Good ("built {0}" -f $a[0]) } else { Warn ("build failed for {0}" -f $a[0]) }
    } else { Warn ("missing {0}" -f $mf) }
}

# 4. VS Code extensions -------------------------------------------------------
Section "4/6  VS Code extensions"
if (Get-Command code -ErrorAction SilentlyContinue) {
    foreach ($e in @("Continue.continue","James-Yu.latex-workshop")) {
        code --install-extension $e --force | Out-Null
        Good ("installed {0}" -f $e)
    }
    Info "LTeX+ : install by hand (search 'LTeX+' in the Extensions panel)"
} else { Warn "VS Code 'code' not on PATH; skipping extensions" }

# 5. Continue config ----------------------------------------------------------
Section "5/6  Continue configuration"
$dst = Join-Path $env:USERPROFILE ".continue\config.yaml"
New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
Copy-Item (Join-Path $config "continue-config.yaml") $dst -Force
Good ("config at {0}" -f $dst)

# 6. Verify -------------------------------------------------------------------
Section "6/6  Health check"
try {
    $tags = Invoke-RestMethod "http://localhost:11434/api/tags" -TimeoutSec 5
    Good ("{0} models installed" -f $tags.models.Count)
} catch { Warn "server not answering" }

Write-Host "`nNext steps (5 min, see docs/02-installation.md):" -ForegroundColor White
Write-Host "  1. Install AnythingLLM from https://anythingllm.com (chat + ask-my-papers)"
Write-Host "  2. Install the 'LTeX+' VS Code extension (offline grammar for LaTeX)"
Write-Host "  3. Open VS Code, press Ctrl+L, and start using Continue."
Write-Host "`nDone." -ForegroundColor Green
