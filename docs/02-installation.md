# 2. Installation

> Two paths are offered. The **automated path** runs one script and is the fastest way to a
> working setup. The **manual path** does the same work step by step so you understand and
> control each piece. Both end in the same place.

- [2.1 Prerequisites](#21-prerequisites)
- [2.2 Automated install (recommended)](#22-automated-install-recommended)
- [2.3 Manual install](#23-manual-install)
- [2.4 Desktop front-ends (both paths)](#24-desktop-front-ends-both-paths)
- [2.5 Verifying the install](#25-verifying-the-install)

## 2.1 Prerequisites

| Requirement | Notes |
| --- | --- |
| Windows 11 | The scripts are PowerShell. |
| NVIDIA GPU, 8 GB VRAM or more | Tested on RTX 5060 Laptop (8 GB). |
| 16 GB RAM (32 GB recommended) | More RAM lets larger models offload smoothly. |
| ~20 GB free disk | For the model set. |
| Git, VS Code, winget | winget ships with Windows 11. |
| A TeX distribution (optional) | MiKTeX or TeX Live, only for LaTeX features. |

Confirm the GPU driver is recent (especially for RTX 50-series). Run `nvidia-smi` in a
terminal; if it prints your GPU and a driver version, you are set.

One-time policy step so Windows allows the local scripts to run for your user only:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## 2.2 Automated install (recommended)

```powershell
git clone https://github.com/nachocz/icz_local_ai_for_research.git
cd icz_local_ai_for_research
./bootstrap.ps1
```

`bootstrap.ps1` is idempotent (safe to re-run) and does the following, printing progress and
skipping anything already done:

1. Installs **Ollama** via winget if it is missing, and starts its background server.
2. Pulls the model set (this is the slow part; on a slow link it retries automatically).
3. Builds the custom assistants **`nacho-writer`** and **`nacho-coder`** from the Modelfiles.
4. Installs the **Continue** and **LaTeX Workshop** VS Code extensions if `code` is on PATH.
5. Copies the Continue configuration to `%USERPROFILE%\.continue\config.yaml`.
6. Runs a health check and prints what, if anything, still needs your attention.

When it finishes, do the two desktop installs in [2.4](#24-desktop-front-ends-both-paths),
then jump to the [Tutorial](03-tutorial.md).

> [!TIP]
> If a download is interrupted, just run `./bootstrap.ps1` again. Ollama resumes partial
> model downloads, and the script will not redo finished steps.

## 2.3 Manual install

Do this if you prefer to understand each step or if the automated script fails partway.

### Step 1 - Install Ollama (the engine)

```powershell
winget install --id Ollama.Ollama -e --accept-package-agreements --accept-source-agreements
```

Open a new terminal so it sees the `ollama` command, then confirm:

```powershell
ollama --version
```

Ollama runs a background server (system tray) that listens on `http://localhost:11434`. If a
later command reports a connection error, open **Ollama** from the Start menu to start it.

### Step 2 - Download the models

From the repository folder:

```powershell
./scripts/pull_models.ps1            # core set, about 15 GB
./scripts/pull_models.ps1 -Extras    # also small/fast general models (optional)
```

The core set:

| Model | Size | Job |
| --- | --- | --- |
| `qwen2.5-coder:7b` | ~4.7 GB | Python/C++ coding, fits fully on an 8 GB GPU |
| `qwen2.5-coder:1.5b` | ~1 GB | fast inline autocomplete in VS Code |
| `qwen2.5:14b` | ~9 GB | reasoning, theory Q&A, writing (GPU + RAM) |
| `nomic-embed-text` | ~0.3 GB | turns documents into vectors for retrieval |

Confirm with `ollama list`.

### Step 3 - Build the custom assistants

```powershell
./scripts/build_assistants.ps1
```

This layers your style and a robotics-coding brief onto the base models, producing
`nacho-writer` (from `qwen2.5:14b`) and `nacho-coder` (from `qwen2.5-coder:7b`). See
[05 Configuration](05-configuration.md) for what is inside and how to change it.

### Step 4 - Install the VS Code coding integration

```powershell
code --install-extension Continue.continue
New-Item -ItemType Directory -Force "$env:USERPROFILE\.continue" | Out-Null
Copy-Item ".\config\continue-config.yaml" "$env:USERPROFILE\.continue\config.yaml" -Force
```

Restart VS Code and open the Continue panel (Ctrl+L). You should see the coding model listed.

### Step 5 - Install the LaTeX build/lint extension

```powershell
code --install-extension James-Yu.latex-workshop
```

Then enable `chktex`: VS Code Settings, search `chktex`, turn on
`Latex-workshop > Linting > Chktex: Enabled`.

## 2.4 Desktop front-ends (both paths)

These two are graphical apps installed by hand. They take about five minutes total.

### AnythingLLM - chat and "ask my papers"

1. Download and install from <https://anythingllm.com>.
2. On first run choose **Ollama** as the LLM provider:
   - Base URL: `http://localhost:11434`
   - Model: `nacho-writer` (or `qwen2.5:14b`)
3. Set the embedder to **Ollama** with model `nomic-embed-text`.
4. Create a **Workspace**, drag in PDFs or `.tex` files, and start asking questions over them.

### LTeX+ - offline grammar and spelling for LaTeX

In VS Code, open the Extensions panel (Ctrl+Shift+X), search **`LTeX+`**, and install the
maintained fork ("LTeX+ - LanguageTool grammar/spell checking"). Open a `.tex` file and it
underlines issues as you type. Set languages under Settings, `Ltex: Language` (for example
`en-US`; add `es` for Spanish documents).

## 2.5 Verifying the install

```powershell
./scripts/health_check.ps1
```

It confirms the Ollama server answers, lists the models and custom assistants, checks the VS
Code extensions and the Continue config, and reports anything missing. A clean run shows the
engine, six models, both assistants, and the two extensions as present. Then continue to the
[Tutorial](03-tutorial.md).
