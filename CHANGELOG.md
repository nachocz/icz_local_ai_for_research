# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project aims to follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-29

First public release.

### Added
- One-command installer `bootstrap.ps1` (installs Ollama, pulls models, builds the custom
  assistants, installs VS Code extensions, copies the Continue config, runs a health check).
- Custom assistants built from Modelfiles:
  - `nacho-writer` (base `qwen2.5:14b`) tuned for concise, technically precise academic prose.
  - `nacho-coder` (base `qwen2.5-coder:7b`) tuned for Python/C++ robotics code.
- Granular scripts: `detect_hardware`, `pull_models`, `build_assistants`, `health_check`,
  `start_languagetool`.
- VS Code integration via Continue (`config/continue-config.yaml`) with chat, edit, and a
  small model for autocomplete.
- Offline writing and LaTeX checking via LTeX+ and LaTeX Workshop.
- Optional retrieval over personal documents via AnythingLLM + `nomic-embed-text`.
- Full documentation set under `docs/` (introduction, installation, tutorial, architecture,
  configuration, models and hardware, troubleshooting, FAQ, uninstall).
- Documentation website built with MkDocs Material and auto-published to GitHub Pages.
- Uninstall guide (`docs/09-uninstall.md`) and helper script (`scripts/uninstall.ps1`).

### Known issues
- The `ollama run` command-line interface can hang in non-interactive / automation contexts.
  Interactive terminals and the HTTP API (used by all front-ends) are unaffected. See
  [docs/07-troubleshooting.md](docs/07-troubleshooting.md).
