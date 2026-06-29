# Contributing

Thanks for your interest. This project is a thin, transparent orchestration layer over
open-source tools, so contributions are mostly about clarity, portability, and good defaults.

## Ways to help

- **Documentation:** fix anything unclear, add a tip you found useful, improve the tutorial.
- **New model presets:** propose a Modelfile for a model that runs well on common hardware,
  with a note on the VRAM/RAM it needs and the speed you observed.
- **Portability:** the scripts are PowerShell for Windows 11. A faithful Bash port for
  Linux/macOS (`scripts/*.sh`, a `bootstrap.sh`) would be very welcome. Keep behavior and
  output identical where possible.
- **Front-end recipes:** configs for other local-friendly front-ends (Open WebUI, LM Studio,
  Cline) that match the same engine and models.

## Ground rules

1. **No paid dependencies and no cloud calls at runtime.** Everything must run offline after
   a one-time download. A contribution that requires an API key will not be merged.
2. **Keep it transparent.** Prefer small, readable scripts over magic. A user should be able
   to read any script top to bottom and understand exactly what it does to their machine.
3. **Be honest about limits.** If a model or setting is weak at something (especially math),
   say so in the docs rather than overselling.
4. **Idempotent scripts.** Running a script twice should be safe and should not duplicate
   work or break an existing install.

## Proposing a change

1. Fork and branch from `main`.
2. Make the change. If it touches behavior, update the relevant file in `docs/` and add a
   line to `CHANGELOG.md` under an `Unreleased` heading.
3. Test on a clean machine or VM if you can, and note in the pull request what hardware and
   OS you verified on.
4. Open a pull request describing the change and the motivation.

## Reporting problems

Open an issue with: your GPU and VRAM, system RAM, OS version, the exact command you ran, and
the full error text. The output of `./scripts/health_check.ps1` and
`./scripts/detect_hardware.ps1` is the most useful thing to paste.
