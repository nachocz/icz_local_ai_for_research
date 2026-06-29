# icz_local_ai

**A free, fully offline AI assistant for researchers and engineers.**
Strong on control theory, math, formal paper writing, and Python/C++ robotics code.
No subscription. No cloud. Nothing leaves your machine.

`icz_local_ai` is a small framework that turns a laptop with a modern NVIDIA GPU into a
private AI workstation. It wires together open-source models and tools so you get, locally:

- a **chat assistant** with a solid background in control, estimation, linear algebra, and analysis,
- a **writing editor** tuned for concise, technically precise academic prose,
- an **in-editor coding assistant** for Python and C++ (robotics-oriented),
- **offline grammar and LaTeX checking**, and
- **"chat with my papers"** retrieval over your own PDFs and notes,

with no API keys, no subscription, and no internet needed after the one-time download.

> [!NOTE]
> This is not a frontier model running in your basement. It is a fast, private, offline
> assistant at roughly the level of a sharp graduate student. It is excellent for drafting,
> explaining, polishing, and recalling. It is **not** a substitute for your own judgment on
> mathematical correctness. See [Introduction, Honest limits](01-introduction.md#15-honest-limits).

## Where to start

| If you want to... | Go to |
| --- | --- |
| Understand what this is and the philosophy | [Introduction](01-introduction.md) |
| Install it | [Installation](02-installation.md) |
| Learn the daily workflow | [Tutorial](03-tutorial.md) |
| Understand how it works | [Architecture](04-architecture.md) |
| Customize models and the writing voice | [Configuration](05-configuration.md) |
| Pick models for your GPU | [Models & hardware](06-models-and-hardware.md) |
| Fix a problem | [Troubleshooting](07-troubleshooting.md) |
| Get a quick answer | [FAQ](08-faq.md) |
| Remove part or all of it | [Uninstall](09-uninstall.md) |

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
swappable. Full details in [Architecture](04-architecture.md).

## Quickstart

```powershell
git clone https://github.com/nachocz/icz_local_ai_for_research.git
cd icz_local_ai_for_research
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
./bootstrap.ps1
```

The one-command installer sets up the engine, models, custom assistants, and the VS Code
integration. Two small desktop installs finish the setup. See [Installation](02-installation.md).

## Requirements

- Windows 11, an NVIDIA GPU with **8 GB VRAM or more**, 16 GB RAM (32 GB recommended),
  ~20 GB free disk, plus Git, VS Code, and winget. See
  [Models & hardware](06-models-and-hardware.md) to size models to your GPU.

## License

[MIT](https://github.com/nachocz/icz_local_ai_for_research/blob/main/LICENSE)
&copy; 2026 Ignacio Cuiral-Zueco. Built on Ollama, Qwen, Continue, AnythingLLM,
LanguageTool, and LaTeX Workshop.
