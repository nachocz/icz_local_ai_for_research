# Verifies the stack is alive and reports what is still missing.
# Run:  ./scripts/health_check.ps1

$ok = "[ ok ]"; $no = "[FAIL]"; $opt = "[opt ]"

Write-Host "===== Local AI stack health =====" -ForegroundColor Cyan

# 1. Ollama installed
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    Write-Host "$ok Ollama installed"
} else {
    Write-Host "$no Ollama not installed  ->  winget install --id Ollama.Ollama -e" -ForegroundColor Red
}

# 2. Ollama service answering
try {
    $tags = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "$ok Ollama service answering on :11434"
    $models = $tags.models | ForEach-Object { $_.name }
    foreach ($want in 'qwen2.5-coder:7b','qwen2.5:14b','nomic-embed-text','nacho-writer:latest','nacho-coder:latest') {
        $short = $want -replace ':latest',''
        $have = $models | Where-Object { $_ -eq $want -or $_ -eq "$short`:latest" -or $_ -eq $short }
        if ($have) { Write-Host ("$ok   model present: {0}" -f $short) }
        else       { Write-Host ("$no   model missing: {0}" -f $short) -ForegroundColor Yellow }
    }
} catch {
    Write-Host "$no Ollama service not answering. Open the Ollama app (Start menu / tray)." -ForegroundColor Red
}

# 3. VS Code extensions
if (Get-Command code -ErrorAction SilentlyContinue) {
    $ext = (& code --list-extensions)
    function Check-Ext($id, $label) {
        if ($ext -contains $id) { Write-Host ("$ok {0} ({1})" -f $label, $id) }
        else { Write-Host ("$no {0} missing  ->  code --install-extension {1}" -f $label, $id) -ForegroundColor Yellow }
    }
    Check-Ext "Continue.continue" "Continue (coding)"
    Check-Ext "James-Yu.latex-workshop" "LaTeX Workshop"
    Write-Host "$opt LTeX+ : search 'LTeX+' in the Extensions panel and install the maintained fork"
} else {
    Write-Host "$no VS Code 'code' command not on PATH" -ForegroundColor Yellow
}

# 4. Continue config in place
$cfg = Join-Path $env:USERPROFILE ".continue\config.yaml"
if (Test-Path $cfg) { Write-Host "$ok Continue config at ~/.continue/config.yaml" }
else { Write-Host "$no Continue config not copied yet (INSTALL.md Step 6)" -ForegroundColor Yellow }

# 5. Optional LanguageTool container
if (Get-Command docker -ErrorAction SilentlyContinue) {
    $lt = (& docker ps --filter "name=languagetool" --format "{{.Names}}")
    if ($lt) { Write-Host "$ok LanguageTool server running (:8010)" }
    else { Write-Host "$opt LanguageTool server not running (optional: ./scripts/start_languagetool.ps1)" }
}

Write-Host "`nLegend: [ ok ] good   [FAIL] needs action   [opt ] optional" -ForegroundColor Cyan
