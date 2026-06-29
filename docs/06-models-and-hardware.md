# 6. Models and hardware

> How to choose models that actually fit your GPU, what the numbers mean, and what speed to
> expect. Run `./scripts/detect_hardware.ps1` to get a recommendation tailored to your
> machine.

- [6.1 The one number that matters: VRAM](#61-the-one-number-that-matters-vram)
- [6.2 Quantization](#62-quantization)
- [6.3 Sizing table](#63-sizing-table)
- [6.4 Offload: using system RAM](#64-offload-using-system-ram)
- [6.5 The default model set](#65-the-default-model-set)
- [6.6 Swapping in other models](#66-swapping-in-other-models)
- [6.7 Speed expectations](#67-speed-expectations)

## 6.1 The one number that matters: VRAM

A model runs fastest when it fits entirely in GPU memory (VRAM). The rough memory a model
needs is its parameter count times the bytes per parameter set by the quantization, plus a
few hundred MB to a couple of GB for the context (KV cache). For the common 4-bit quantization
(`Q4`), the weights alone are roughly:

| Parameters | Approx. weights at Q4 |
| --- | --- |
| 1.5B | ~1 GB |
| 7-8B | ~5 GB |
| 14B | ~9 GB |
| 32B | ~20 GB |

So on an 8 GB GPU, a 7-8B model fits with room for context, a 14B does not fully fit (it
spills into RAM, see [6.4](#64-offload-using-system-ram)), and a 32B is mostly on the CPU.

## 6.2 Quantization

Quantization shrinks a model by storing its weights at lower precision. Less precision means
less memory and faster inference, at a small and usually acceptable quality cost.

| Tag | Bits | Trade-off |
| --- | --- | --- |
| `Q8_0` | 8-bit | near-full quality, large |
| `Q5_K_M` | 5-bit | very good quality, moderate size |
| `Q4_K_M` | 4-bit | the standard sweet spot; default for most Ollama tags |
| `Q3`, `Q2` | 3-2 bit | smallest, noticeable quality loss; avoid unless desperate for space |

When you pull `qwen2.5:14b`, Ollama gives you a sensible default quant (`Q4_K_M`). You only
need to think about this if you want to trade quality for fit, for example pulling a specific
`...:14b-instruct-q5_K_M` tag.

## 6.3 Sizing table

| Your VRAM | Runs fully on GPU | With RAM offload | Recommended daily driver |
| --- | --- | --- | --- |
| 8 GB | 7-8B | 14B (good, slower) | 7-8B for code, 14B for writing |
| 12 GB | up to ~14B | up to ~32B (slow) | 14B |
| 16 GB | 14B comfortably | 32B (usable) | 14B, try 32B |
| 24 GB | up to ~32B | up to ~70B (slow) | 32B |

These are guidelines for `Q4` weights with a modest context window. Larger `num_ctx` shifts
each row down a little.

## 6.4 Offload: using system RAM

When a model does not fit in VRAM, Ollama keeps as many layers as possible on the GPU and
runs the rest on the CPU, reading those layers from system RAM. This is why **32 GB of RAM is
recommended**: it lets an 8 GB GPU run a 14B model by offloading roughly half of it.

You can see the split after a request:

```powershell
ollama ps
# NAME                 ...  PROCESSOR          ...
# nacho-writer:latest  ...  43%/57% CPU/GPU    ...
```

A higher GPU percentage means more of the model is on the card and the faster it runs. The
cost of offload is speed, not capability: the answers are the same, they just arrive slower.

## 6.5 The default model set

| Model | Role | Why it was chosen |
| --- | --- | --- |
| `qwen2.5-coder:7b` | coding | strong open coder at a size that fits 8 GB fully |
| `qwen2.5-coder:1.5b` | autocomplete | small enough to keep up with typing |
| `qwen2.5:14b` | reasoning, writing | good general and technical quality with RAM offload |
| `nomic-embed-text` | embeddings | compact, solid retrieval embeddings |

The Qwen 2.5 family was chosen for strong math and code performance at these sizes and for
good multilingual coverage. Newer releases (for example the Qwen 3 family) work the same way;
to use one, pull it and change the `FROM` line in the relevant Modelfile.

## 6.6 Swapping in other models

Any model in the Ollama registry works. Practical alternatives by need:

- **Stronger reasoning at 8 GB:** a current `phi-4`-class or `qwen3`-class model around 14B.
- **Faster general chat:** `qwen2.5:7b` or `llama3.2:3b` (pull with `pull_models.ps1 -Extras`).
- **Math-leaning:** a `qwen2.5-math` variant, with the standing caveat that you still must
  verify any proof yourself.
- **Bigger when you upgrade GPUs:** `qwen2.5:32b` or a 70B at higher VRAM.

To switch the writing assistant to a different base:

```powershell
ollama pull <new-model>
# edit the FROM line in config/Modelfile.writer
./scripts/build_assistants.ps1
```

## 6.7 Speed expectations

On the reference machine (RTX 5060 Laptop, 8 GB VRAM, 32 GB RAM):

| Model | Where it runs | First response (incl. load) | Warm response |
| --- | --- | --- | --- |
| `qwen2.5-coder:1.5b` | full GPU | ~5 s | very fast |
| `qwen2.5-coder:7b` | full GPU | ~7 s | fast (tens of tokens/s) |
| `nacho-writer` (14B) | 57% GPU / 43% CPU | ~24 s | readable (slower) |
| 32B (if pulled) | mostly CPU | tens of seconds | slow, occasional use |

The first call after idle includes loading the model from disk; subsequent calls while it
stays warm are much quicker. If a model feels far slower than this, confirm it is actually on
the GPU with `nvidia-smi` during a request and see [07 Troubleshooting](07-troubleshooting.md).
