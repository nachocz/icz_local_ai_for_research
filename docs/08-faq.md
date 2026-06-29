# 8. FAQ

**Is this really free?**
Yes. The tools are open-source and the models are open-weight. There is no subscription and
no per-use cost. You spend disk, electricity, and a one-time download.

**Does it work fully offline?**
Yes, after the initial model download. The serving path makes no external calls. You can
disconnect the network and everything keeps working.

**Is my data sent anywhere?**
No. Generation, embeddings, and the document store all run on your machine. This is the main
reason to prefer it for unpublished work and proprietary code.

**How good is it compared to a frontier cloud assistant?**
For drafting, polishing, recalling standard theory, and writing everyday code, it is close
enough to be genuinely useful. For hard reasoning, novel proofs, and large-codebase work, a
frontier cloud model is clearly better. Think "fast, private, offline graduate-student
assistant," not "frontier model at home." See
[01 Introduction, section 1.5](01-introduction.md#15-honest-limits).

**Can I trust it to check my math or proofs?**
No. Local 7-14B models produce confident, sometimes wrong algebra. Use a computer algebra
system and your own judgment. The writing assistant is told to flag suspicious math, not to
fix it.

**Do I need a powerful GPU?**
You need an NVIDIA GPU with 8 GB of VRAM or more. More VRAM lets you run larger models faster.
See [06 Models and hardware](06-models-and-hardware.md).

**Will it run on AMD or Apple Silicon?**
Ollama supports both, so the engine and models will run. The scripts here are written for
Windows with an NVIDIA GPU; a Linux/macOS port is a welcome contribution
([CONTRIBUTING.md](https://github.com/nachocz/icz_local_ai/blob/main/CONTRIBUTING.md)).

**How do I keep it current with new papers or knowledge?**
Add documents to an AnythingLLM workspace. Retrieval handles new knowledge with no retraining.
Adding a PDF takes seconds.

**Can I retrain or fine-tune the model on my own writing?**
That is a larger project and usually unnecessary. A good system prompt (the approach used
here) plus retrieval covers most needs. Fine-tuning is the optimization, not the starting
point, and it does not reliably add factual knowledge; retrieval does that better.

**How do I change the writing style or the assistant's behavior?**
Edit the `SYSTEM` block in the relevant Modelfile and run `./scripts/build_assistants.ps1`.
See [05 Configuration](05-configuration.md).

**How much disk does it use?**
The default model set is roughly 15 GB. Models live in `%USERPROFILE%\.ollama`. Remove ones
you do not use with `ollama rm <name>`.

**How do I update everything later?**
`winget upgrade --id Ollama.Ollama -e` for the engine, `ollama pull <model>` for a newer
model (rebuild the assistant afterward if you changed its base), and update VS Code
extensions from the Extensions panel.

**Why Qwen 2.5 and not the newest model?**
It is a strong, well-tested choice at the sizes that fit common GPUs. Newer models work
identically; pull one and change the `FROM` line. The framework is model-agnostic.

**Can I use it without VS Code or AnythingLLM?**
Yes. The engine and a model are the only required pieces. The front-ends are additive; install
only the ones you want.
