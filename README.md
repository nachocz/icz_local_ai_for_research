<div align="center">

# icz_local_ai

**A free, fully offline AI assistant for researchers and engineers.**
Strong on control theory, math, formal paper writing, and Python/C++ robotics code.
No subscription. No cloud. Nothing leaves your machine.

![Platform](https://img.shields.io/badge/platform-Windows%2011-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Runtime](https://img.shields.io/badge/runtime-Ollama-black)
![GPU](https://img.shields.io/badge/GPU-NVIDIA%208GB%2B-76b900)

</div>

---

`icz_local_ai` is a small framework that turns a laptop with a modern NVIDIA GPU into a
private AI workstation. It wires together open-source models and tools so you get, locally:

- a **chat assistant** with a solid background in control, estimation, linear algebra, and analysis,
- a **writing editor** tuned for concise, technically precise academic prose,
- an **in-editor coding assistant** for Python and C++ (robotics-oriented),
- **offline grammar and LaTeX checking**, and
- **"chat with my papers"** retrieval over your own PDFs and notes,

with **no API keys, no subscription, and no internet needed** after the one-time download.

> [!NOTE]
> This is not a frontier model running in your basement. It is a fast, private,
> offline assistant at roughly the level of a sharp graduate student. It is excellent for
> drafting, explaining, polishing, and recalling. It is **not** a substitute for your own
> judgment on mathematical correctness. See [What it is and is not good at](#what-it-is-and-is-not-good-at).

---

## Table of contents

- [Why this exists](#why-this-exists)
- [What you get](#what-you-get)
- [Architecture at a glance](#architecture-at-a-glance)
- [Requirements](#requirements)
- [Quickstart](#quickstart)
- [What it is and is not good at](#what-it-is-and-is-not-good-at)
- [Documentation](#documentation)
- [Repository layout](#repository-layout)
- [Make it your own](#make-it-your-own)
- [License](#license)

---

## Why this exists

Cloud AI assistants are powerful but they are metered, online, and they send your work to
someone else's servers. For a researcher that means recurring cost, a hard dependency on
connectivity, and your unpublished drafts and ideas leaving your control.

Modern open-weight models plus a consumer GPU are now good enough that, for a large slice of
day-to-day work (drafting and polishing prose, recalling standard theory, writing and
explaining code, checking typos, searching your own library), you do not need the cloud at
all. `icz_local_ai` packages that into a setup you install once and own forever.

## What you get

| Capability | Tool | Runs on |
| --- | --- | --- |
| Chat and "ask my papers" (RAG) | AnythingLLM + Ollama | your GPU + RAM |
| In-editor coding (chat, edit, autocomplete) | Continue (VS Code) + Ollama | your GPU |
| Style-tuned academic writing editor | `nacho-writer` (custom model) | your GPU + RAM |
| Robotics-focused coder | `nacho-coder` (custom model) | your GPU |
| Offline grammar and spelling for LaTeX | LTeX+ (VS Code) | CPU |
| LaTeX linting (`chktex`) and build | LaTeX Workshop (VS Code) | CPU |

Everything is open source and free.

## Architecture at a glance

```
            +-------------------------------------------------------------+
            |                       FRONT-ENDS                            |
  CHAT  --> |  AnythingLLM (desktop)   chat + retrieval over your PDFs    |
  CODE  --> |  Continue (VS Code)      chat / edit / autocomplete         |
  WRITE --> |  LTeX+ & LaTeX Workshop  offline grammar + LaTeX lint       |
            +----------------------------+--------------------------------+
                                         |  HTTP, localhost:11434
                                         v
            +-------------------------------------------------------------+
  ENGINE--> |  OLLAMA   loads model weights, serves an OpenAI-style API   |
            +----------------------------+--------------------------------+
                                         |
                                         v
            +-------------------------------------------------------------+
  MODELS--> |  qwen2.5:14b  qwen2.5-coder:7b  nomic-embed-text  + custom  |
            +-------------------------------------------------------------+
```

A single local engine (Ollama) serves several front-ends over `localhost`. Models are
swappable. The custom assistants (`nacho-writer`, `nacho-coder`) are thin recipes layered on
the base models. Full details in [docs/04-architecture.md](docs/04-architecture.md).

## Requirements

- **OS:** Windows 11 (the scripts are PowerShell; the concepts port to Linux/macOS).
- **GPU:** NVIDIA with **8 GB VRAM or more** (tested on an RTX 5060 Laptop, 8 GB).
- **RAM:** 16 GB minimum, **32 GB recommended** (lets 14B models offload comfortably).
- **Disk:** ~20 GB free for the model set.
- **Preinstalled:** [Git](https://git-scm.com/), [VS Code](https://code.visualstudio.com/),
  and [winget](https://learn.microsoft.com/windows/package-manager/winget/) (ships with
  Windows 11). A TeX distribution (MiKTeX or TeX Live) if you want LaTeX features.

See [docs/06-models-and-hardware.md](docs/06-models-and-hardware.md) to size models to your
specific GPU.

## Quickstart

```powershell
# 1. Get the framework
git clone https://github.com/nachocz/icz_local_ai.git
cd icz_local_ai

# 2. Allow local scripts for your user (one time)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 3. One command: installs Ollama, pulls models, builds assistants,
#    installs VS Code extensions, and verifies everything.
./bootstrap.ps1
```

The model download is several GB and is the only slow part. When it finishes, two desktop
front-ends are installed by hand in five minutes (AnythingLLM and the LTeX+ extension); the
script prints the exact steps, and they are in [docs/02-installation.md](docs/02-installation.md).

Prefer to do it step by step and understand each piece? Follow
[docs/02-installation.md](docs/02-installation.md) instead of `bootstrap.ps1`.

## What it is and is not good at

**Good at**
- Recalling and explaining classic control, estimation, analysis, and linear algebra.
- Drafting and polishing academic prose; tightening paragraphs; removing filler.
- Catching typos, grammar, and LaTeX issues (handled by LTeX+ and `chktex`, deterministic).
- Writing solid Python and C++ robotics snippets (numpy/scipy/MuJoCo, Eigen/ROS/libfranka).
- Explaining unfamiliar code and acting as a rubber duck.

**Not to be trusted with**
- **Verifying mathematics or proofs.** A local 7-14B model will produce confident, wrong
  algebra. Keep proofs in a computer algebra system and your own head. The writing assistant
  is told to flag suspicious math, not to fix it.
- **Whole-codebase correctness** or subtle numerical and concurrency bugs. It writes good
  functions; it does not reason over a large system like a frontier model.

This honesty is the point: use it where local models are strong, and keep a human in the
loop where they are weak.

## Documentation

| Document | What is inside |
| --- | --- |
| [01 Introduction](docs/01-introduction.md) | Purpose, philosophy, who it is for, the offline guarantee |
| [02 Installation](docs/02-installation.md) | Step-by-step setup with verification at every step |
| [03 Tutorial](docs/03-tutorial.md) | A guided first hour: writing, coding, and chatting with your papers |
| [04 Architecture](docs/04-architecture.md) | How the pieces fit, data flow, the role of Ollama, the API |
| [05 Configuration](docs/05-configuration.md) | Modelfiles, the style prompt, Continue config, customization |
| [06 Models and hardware](docs/06-models-and-hardware.md) | Choosing models, VRAM math, quantization, speed |
| [07 Troubleshooting](docs/07-troubleshooting.md) | Every failure we hit and how to fix it |
| [08 FAQ](docs/08-faq.md) | Short answers to common questions |

## Repository layout

```
icz_local_ai/
  README.md              this file
  bootstrap.ps1          one-command installer
  LICENSE                MIT
  CONTRIBUTING.md        how to propose changes
  CHANGELOG.md           version history
  docs/                  full documentation (see table above)
  config/
    system_prompt_style.txt   the writing-style instructions
    Modelfile.writer          recipe for the writing assistant
    Modelfile.coder           recipe for the coding assistant
    continue-config.yaml      VS Code Continue settings
  scripts/
    detect_hardware.ps1       print GPU/RAM and model recommendations
    pull_models.ps1           download the models
    build_assistants.ps1      build the custom assistants
    health_check.ps1          verify the whole stack
    start_languagetool.ps1    optional local grammar server (Docker)
```

## Make it your own

The two custom assistants and the writing style are examples, not gospel. To adapt the
framework to your voice and field, edit
[config/system_prompt_style.txt](config/system_prompt_style.txt) and the `SYSTEM` blocks in
the Modelfiles, then rebuild. Full instructions in
[docs/05-configuration.md](docs/05-configuration.md).

## License

[MIT](LICENSE) © 2026 Ignacio Cuiral-Zueco. Built on open-source projects:
[Ollama](https://github.com/ollama/ollama), [Qwen](https://github.com/QwenLM/Qwen2.5),
[Continue](https://github.com/continuedev/continue),
[AnythingLLM](https://github.com/Mintplex-Labs/anything-llm),
[LanguageTool](https://github.com/languagetool-org/languagetool), and
[LaTeX Workshop](https://github.com/James-Yu/LaTeX-Workshop). All trademarks belong to their
owners.
