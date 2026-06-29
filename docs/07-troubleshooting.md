# 7. Troubleshooting

> Concrete fixes for the problems you are most likely to hit, including the ones encountered
> while building this project. Start by running `./scripts/health_check.ps1`; it pinpoints
> most issues.

- [7.1 Ollama and connection](#71-ollama-and-connection)
- [7.2 Model downloads](#72-model-downloads)
- [7.3 Performance](#73-performance)
- [7.4 The `ollama run` hang](#74-the-ollama-run-hang)
- [7.5 VS Code and Continue](#75-vs-code-and-continue)
- [7.6 Writing and LaTeX checking](#76-writing-and-latex-checking)
- [7.7 Scripts will not run](#77-scripts-will-not-run)

## 7.1 Ollama and connection

**Symptom:** a client says "connection refused" or a command returns
`dial tcp 127.0.0.1:11434: ... refused`.

**Cause:** the Ollama server is not running. It normally starts with Windows, but it can be
closed or fail to start in a fresh session.

**Fix:** open **Ollama** from the Start menu (it lives in the system tray), or start it from
a terminal:

```powershell
& "$env:LOCALAPPDATA\Programs\Ollama\ollama app.exe"
```

Confirm it answers:

```powershell
Invoke-RestMethod http://localhost:11434/api/tags
```

## 7.2 Model downloads

**Symptom:** a pull stalls, errors, or seems to lose progress.

**Cause:** usually a slow or flaky connection. The default tags are several GB.

**Fixes:**
- Re-run the pull. Ollama resumes from where it stopped; it does not start over.
- `scripts/pull_models.ps1` and `bootstrap.ps1` already retry automatically.
- Check actual progress on disk if a pull looks frozen:

```powershell
Get-ChildItem "$env:USERPROFILE\.ollama\models\blobs" -Filter "*partial*" |
  Select-Object Name, @{n='MB';e={[math]::Round($_.Length/1MB,1)}}, LastWriteTime
```

A growing size with a recent `LastWriteTime` means it is downloading fine.

## 7.3 Performance

**Symptom:** generation is far slower than the figures in
[06 Models and hardware](06-models-and-hardware.md).

**Checks:**
- While a request runs, confirm the GPU is busy:

```powershell
nvidia-smi
ollama ps   # shows the CPU/GPU split for the loaded model
```

- If a model that should fit is running on the CPU, update Ollama and the NVIDIA driver
  (50-series GPUs need recent versions):

```powershell
winget upgrade --id Ollama.Ollama -e
```

- If you are out of VRAM, use a smaller model, lower `num_ctx` in the Modelfile, or close
  other GPU-hungry apps (browsers with many tabs, games).

## 7.4 The `ollama run` hang

**Symptom:** `ollama run <model> "prompt"` produces no output and never returns, especially
when called from a script, a background task, or any non-interactive shell.

**Cause:** the `ollama run` CLI expects an interactive terminal and can deadlock without one.

**Fix:** use the HTTP API for any scripted generation. It is reliable and is what every
front-end uses:

```powershell
$body = @{ model="nacho-coder"; prompt="square(x) in one line of Python"; stream=$false } | ConvertTo-Json
(Invoke-RestMethod http://localhost:11434/api/generate -Method Post -Body $body).response
```

In your own interactive terminal, `ollama run` works normally.

## 7.5 VS Code and Continue

- **Continue shows no model or "connection refused":** Ollama is not running (see [7.1](#71-ollama-and-connection)), then reload VS Code.
- **A model name is greyed out or errors:** the model is not pulled. Run `ollama list` and
  pull anything missing. Confirm `continue-config.yaml` names match `ollama list` exactly.
- **Autocomplete does nothing:** ensure the autocomplete model in the config
  (`qwen2.5-coder:1.5b`) is actually installed, and that Continue's autocomplete is enabled.
- **Edits to the config have no effect:** the active file is
  `%USERPROFILE%\.continue\config.yaml`. Re-copy it from this repo after changes.

## 7.6 Writing and LaTeX checking

- **LTeX+ flags every technical term:** add them to the dictionary with the quick-fix, or set
  `Ltex: Language` correctly per document (`en-US` vs `es`).
- **No `chktex` warnings:** confirm `chktex` is installed (it ships with MiKTeX / TeX Live)
  and that `Latex-workshop > Linting > Chktex: Enabled` is on.
- **LTeX+ feels slow on first open:** it loads its language model once per session; later
  files are fast.

## 7.7 Scripts will not run

**Symptom:** "running scripts is disabled on this system."

**Fix:** allow local scripts for your user (one time):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Or run a single script without changing the policy:

```powershell
powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

---

If none of this helps, gather the output of `./scripts/health_check.ps1` and
`./scripts/detect_hardware.ps1`, your OS and GPU details, and the exact error text, and open
an issue.
