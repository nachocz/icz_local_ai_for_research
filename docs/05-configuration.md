# 5. Configuration

> Every knob in the project, what it does, and how to change it safely. After any change to a
> Modelfile, rebuild with `./scripts/build_assistants.ps1`.

- [5.1 The configuration files](#51-the-configuration-files)
- [5.2 The writing style prompt](#52-the-writing-style-prompt)
- [5.3 Modelfiles explained](#53-modelfiles-explained)
- [5.4 Sampling and context parameters](#54-sampling-and-context-parameters)
- [5.5 The Continue configuration](#55-the-continue-configuration)
- [5.6 Make it your own](#56-make-it-your-own)

## 5.1 The configuration files

| File | Controls |
| --- | --- |
| `config/system_prompt_style.txt` | the human-readable writing-style rules |
| `config/Modelfile.writer` | the `nacho-writer` assistant (base, prompt, parameters) |
| `config/Modelfile.coder` | the `nacho-coder` assistant |
| `config/continue-config.yaml` | which models VS Code uses, and for what |

## 5.2 The writing style prompt

`system_prompt_style.txt` is the single source of the writing voice. It is plain English
instructions, kept separate so it is easy to read and edit. The shipped version asks for:
concise, technically precise prose; flowing paragraphs rather than bullet lists; no
em-dashes; no filler words; physical intuition alongside formal statements; and an explicit
rule to flag suspicious mathematics rather than rephrase over it.

The same content is embedded in `Modelfile.writer` as the `SYSTEM` block. If you change the
style, change it in the Modelfile (that is what is actually compiled into the assistant) and
keep `system_prompt_style.txt` in sync as the readable copy.

## 5.3 Modelfiles explained

A Modelfile is a short recipe. `Modelfile.writer`, annotated:

```dockerfile
FROM qwen2.5:14b                 # base model the assistant is built on

PARAMETER temperature 0.3        # low = faithful edits, high = more creative
PARAMETER top_p 0.9
PARAMETER num_ctx 8192           # context window in tokens (see 5.4)

SYSTEM """
...the writing-style instructions...
"""
```

Build it:

```powershell
ollama create nacho-writer -f config/Modelfile.writer
```

`nacho-coder` is the same shape with `FROM qwen2.5-coder:7b`, a lower temperature (0.2 for
more deterministic code), and a system prompt about robotics Python/C++ that tells the model
to flag numerical and stability concerns and to admit when it is unsure of an API rather than
inventing one.

## 5.4 Sampling and context parameters

| Parameter | Meaning | Guidance |
| --- | --- | --- |
| `temperature` | randomness of the output | 0.2-0.3 for editing and code; 0.6-0.8 for brainstorming |
| `top_p` | nucleus sampling cutoff | 0.9 is a fine default |
| `num_ctx` | context window size, in tokens | larger reads more at once but uses more VRAM/RAM |

`num_ctx` is the one to understand. The context window holds the prompt plus the generated
reply, and its memory cost (the "KV cache") grows with the window and the model size. On an
8 GB GPU, 8192 is a good balance. Raise it (for example 16384) only if you routinely feed
long sections and have RAM headroom; lower it if you hit out-of-memory errors. Pushing very
long documents into the context is usually worse than retrieval (RAG); see
[04 Architecture](04-architecture.md).

## 5.5 The Continue configuration

`continue-config.yaml` maps models to roles. The shipped file:

```yaml
models:
  - name: Coder (Qwen2.5-Coder 7B)
    provider: ollama
    model: qwen2.5-coder:7b
    roles: [chat, edit, apply]

  - name: Reasoning (Qwen2.5 14B)
    provider: ollama
    model: qwen2.5:14b
    roles: [chat]

  - name: Autocomplete (Qwen2.5-Coder 1.5B)
    provider: ollama
    model: qwen2.5-coder:1.5b
    roles: [autocomplete]

  - name: Embeddings (nomic)
    provider: ollama
    model: nomic-embed-text
    roles: [embed]
```

- A model can hold several roles. The 7B coder handles `chat`, in-place `edit`, and `apply`.
- `autocomplete` should be a small, fast model; the 1.5B keeps suggestions responsive.
- `embed` powers Continue's `@codebase` indexing.
- The active file lives at `%USERPROFILE%\.continue\config.yaml`. Re-copy it from this repo
  after edits, or edit it in place. Some older Continue versions use `config.json`; if so,
  open Continue's settings once to create the default file, then translate these fields.

## 5.6 Make it your own

The assistants and the style are a starting point, not a fixed identity. To adapt the
framework:

1. **Change the voice.** Edit the `SYSTEM` block in `Modelfile.writer` (and the readable copy
   in `system_prompt_style.txt`) to describe your field and preferences. Rebuild.
2. **Rename the assistants.** If `nacho-*` does not suit you, build under a different name:
   `ollama create my-writer -f config/Modelfile.writer`, then update any references in
   `continue-config.yaml` and AnythingLLM. The base models are unaffected.
3. **Swap base models.** Change the `FROM` line to any model you have pulled (see
   [06 Models and hardware](06-models-and-hardware.md) for choices that fit common GPUs), then
   rebuild.
4. **Tune behavior.** Adjust `temperature` and `num_ctx` per the table in [5.4](#54-sampling-and-context-parameters).

Rebuilding is fast and never re-downloads weights, so experiment freely.
