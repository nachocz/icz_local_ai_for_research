# OPTIONAL. Runs a local LanguageTool grammar server in Docker for general (non-LaTeX)
# text. For your LaTeX papers, the LTeX+ VS Code extension is the better tool and needs
# no server. Use this only if you want grammar checking for emails, markdown, etc.
#
# Run:   ./scripts/start_languagetool.ps1
# Stop:  docker stop languagetool
# Test:  open http://localhost:8010 in a browser

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker not found. Install Docker Desktop, or just use the LTeX+ VS Code extension." -ForegroundColor Yellow
    exit 1
}

$existing = (& docker ps -a --filter "name=languagetool" --format "{{.Names}}")
if ($existing -eq "languagetool") {
    Write-Host "Container exists; starting it..." -ForegroundColor Cyan
    & docker start languagetool
} else {
    Write-Host "Pulling and starting LanguageTool (first run downloads the image)..." -ForegroundColor Cyan
    & docker run -d --name languagetool --restart unless-stopped -p 8010:8010 erikvl87/languagetool
}

Write-Host "`nLanguageTool should be at http://localhost:8010" -ForegroundColor Green
Write-Host "Point a LanguageTool client (browser extension, editor plugin) at that URL."
