# Builds the custom assistants (nacho-writer, nacho-coder) from the Modelfiles.
# Run:  ./scripts/build_assistants.ps1
# Re-run this after editing the Modelfiles or changing their FROM base model.

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "Ollama is not installed. See INSTALL.md Step 1." -ForegroundColor Red
    exit 1
}

$configDir = Join-Path (Split-Path $PSScriptRoot -Parent) "config"

function Build-Assistant($name, $file) {
    $path = Join-Path $configDir $file
    if (-not (Test-Path $path)) {
        Write-Host ("Missing Modelfile: {0}" -f $path) -ForegroundColor Red
        return
    }
    Write-Host ("`n--> building {0} from {1}" -f $name, $file) -ForegroundColor Cyan
    & ollama create $name -f $path
    if ($LASTEXITCODE -eq 0) {
        Write-Host ("    built {0}" -f $name) -ForegroundColor Green
    } else {
        Write-Host ("    build failed for {0} (is the FROM base model pulled?)" -f $name) -ForegroundColor Yellow
    }
}

Build-Assistant "nacho-writer" "Modelfile.writer"
Build-Assistant "nacho-coder"  "Modelfile.coder"

Write-Host "`nTry it:" -ForegroundColor Green
Write-Host '  ollama run nacho-writer "Tighten: The method, which is novel, is able to be used."'
