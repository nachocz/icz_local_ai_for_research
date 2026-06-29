# Prints your GPU, RAM, disk, and a model-size recommendation.
# Run:  ./scripts/detect_hardware.ps1

Write-Host "===== GPU =====" -ForegroundColor Cyan
$vramMB = 0
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $line = (& nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader)
    Write-Host $line
    $m = [regex]::Match($line, '(\d+)\s*MiB')
    if ($m.Success) { $vramMB = [int]$m.Groups[1].Value }
} else {
    Write-Host "nvidia-smi not found. Is the NVIDIA driver installed?"
}

Write-Host "`n===== RAM =====" -ForegroundColor Cyan
$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Write-Host ("Total RAM: {0} GB" -f $ramGB)

Write-Host "`n===== DISK (C:) =====" -ForegroundColor Cyan
$d = Get-PSDrive C
Write-Host ("Free: {0} GB" -f [math]::Round($d.Free / 1GB, 0))

Write-Host "`n===== RECOMMENDATION =====" -ForegroundColor Green
$vramGB = [math]::Round($vramMB / 1024, 1)
Write-Host ("Detected ~{0} GB VRAM, {1} GB RAM." -f $vramGB, $ramGB)
if ($vramMB -ge 15000) {
    Write-Host "Run 14B fully on GPU (fast). 32B works with offload. Daily driver: 14B."
} elseif ($vramMB -ge 7000) {
    Write-Host "Run 7-8B fully on GPU (fast). 14B with RAM offload (good). 32B slow but possible."
    Write-Host "This is your machine. The pull_models.ps1 defaults are tuned for it."
} else {
    Write-Host "Stick to 3-8B models. Larger ones will be slow."
}
