# uninstall.ps1 - remove what icz_local_ai installed, with confirmation.
#
#   ./scripts/uninstall.ps1                 show the plan, remove nothing
#   ./scripts/uninstall.ps1 -Models         remove pulled models + custom assistants
#   ./scripts/uninstall.ps1 -All            remove everything it can (asks per step)
#   ./scripts/uninstall.ps1 -All -Yes       remove everything, no prompts
#
# Safe by design: it never deletes your documents, never uninstalls AnythingLLM, and never
# deletes the repository folder. Those are left for you (see docs/09-uninstall.md).

param(
    [switch]$Models,        # remove the model store (%USERPROFILE%\.ollama) and assistants
    [switch]$Engine,        # winget uninstall Ollama
    [switch]$Extensions,    # uninstall the Continue and LaTeX Workshop VS Code extensions
    [switch]$Config,        # remove the Continue config (%USERPROFILE%\.continue)
    [switch]$LanguageTool,  # remove the optional LanguageTool Docker container/image
    [switch]$All,
    [switch]$Yes
)

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path","User")

if ($All) { $Models = $Engine = $Extensions = $Config = $LanguageTool = $true }

if (-not ($Models -or $Engine -or $Extensions -or $Config -or $LanguageTool)) {
    Write-Host "icz_local_ai uninstaller - nothing selected, showing the plan only." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  -Models        remove pulled models + assistants  ($env:USERPROFILE\.ollama)"
    Write-Host "  -Engine        winget uninstall Ollama"
    Write-Host "  -Extensions    uninstall Continue + LaTeX Workshop VS Code extensions"
    Write-Host "  -Config        remove Continue config             ($env:USERPROFILE\.continue)"
    Write-Host "  -LanguageTool  remove the optional LanguageTool Docker container/image"
    Write-Host "  -All           all of the above        -Yes  skip confirmations"
    Write-Host ""
    Write-Host "Not handled here (remove by hand, see docs/09-uninstall.md):" -ForegroundColor Yellow
    Write-Host "  AnythingLLM (desktop app) and the cloned repository folder."
    return
}

function Confirm-Step($msg) {
    if ($Yes) { return $true }
    $a = Read-Host ("{0} [y/N]" -f $msg)
    return ($a -eq 'y' -or $a -eq 'Y')
}

if ($Models) {
    if (Confirm-Step "Remove ALL Ollama models and custom assistants (frees ~15 GB)?") {
        if (Get-Command ollama -ErrorAction SilentlyContinue) {
            foreach ($m in 'nacho-writer','nacho-coder') { ollama rm $m 2>$null }
        }
        Remove-Item -Recurse -Force "$env:USERPROFILE\.ollama" -ErrorAction SilentlyContinue
        Write-Host "[ ok ] models removed" -ForegroundColor Green
    }
}

if ($Engine) {
    if (Confirm-Step "Uninstall the Ollama engine?") {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget uninstall --id Ollama.Ollama -e
        } else { Write-Host "winget not found; uninstall Ollama from Settings > Apps" -ForegroundColor Yellow }
        Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Ollama" -ErrorAction SilentlyContinue
        Write-Host "[ ok ] engine removed" -ForegroundColor Green
    }
}

if ($Extensions) {
    if (Confirm-Step "Uninstall the Continue and LaTeX Workshop VS Code extensions?") {
        if (Get-Command code -ErrorAction SilentlyContinue) {
            code --uninstall-extension Continue.continue 2>$null
            code --uninstall-extension James-Yu.latex-workshop 2>$null
            $ltex = (code --list-extensions | Select-String -Pattern "ltex")
            if ($ltex) { Write-Host ("Remove LTeX+ by hand: code --uninstall-extension {0}" -f $ltex) -ForegroundColor Yellow }
            Write-Host "[ ok ] extensions removed" -ForegroundColor Green
        } else { Write-Host "VS Code 'code' not on PATH; remove extensions from the Extensions panel" -ForegroundColor Yellow }
    }
}

if ($Config) {
    if (Confirm-Step "Remove the Continue config ($env:USERPROFILE\.continue)?") {
        Remove-Item -Recurse -Force "$env:USERPROFILE\.continue" -ErrorAction SilentlyContinue
        Write-Host "[ ok ] Continue config removed" -ForegroundColor Green
    }
}

if ($LanguageTool) {
    if (Confirm-Step "Remove the LanguageTool Docker container and image?") {
        if (Get-Command docker -ErrorAction SilentlyContinue) {
            docker stop languagetool 2>$null
            docker rm languagetool 2>$null
            docker rmi erikvl87/languagetool 2>$null
            Write-Host "[ ok ] LanguageTool removed" -ForegroundColor Green
        } else { Write-Host "docker not found; nothing to remove" -ForegroundColor Yellow }
    }
}

Write-Host "`nDone. To finish a full removal, also uninstall AnythingLLM and delete this repo folder." -ForegroundColor Cyan
Write-Host "See docs/09-uninstall.md for those manual steps."
