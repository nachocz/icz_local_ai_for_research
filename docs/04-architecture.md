# 4. Architecture

> How the parts fit together, what talks to what, and why. This is the reference for anyone
> who wants to extend, debug, or simply trust the system.

- [4.1 Design principles](#41-design-principles)
- [4.2 The layers](#42-the-layers)
- [4.3 The engine: Ollama](#43-the-engine-ollama)
- [4.4 Models and custom assistants](#44-models-and-custom-assistants)
- [4.5 The front-ends](#45-the-front-ends)
- [4.6 Retrieval (RAG) data flow](#46-retrieval-rag-data-flow)
- [4.7 Where data lives on disk](#47-where-data-lives-on-disk)
- [4.8 What is and is not a runtime dependency](#48-what-is-and-is-not-a-runtime-dependency)

## 4.1 Design principles

1. **One engine, many front-ends.** A single local server (Ollama) holds the models in
   memory and answers every client over HTTP. Front-ends are thin and interchangeable.
2. **Models are data, not code.** Swapping a model is a download and a config line, never a
   code change. Custom assistants are declarative recipes (Modelfiles), not programs.
3. **Deterministic where possible.** Spelling, grammar, and LaTeX linting are handled by
   classical tools, not the model, because they are more reliable and need no GPU.
4. **No runtime cloud dependency.** Nothing in the serving path calls an external API.

## 4.2 The layers

```
  +--------------------------------------------------------------------------+
  |  FRONT-ENDS (clients)                                                     |
  |                                                                          |
  |  AnythingLLM        Continue (VS Code)      LTeX+ / LaTeX Workshop       |
  |  chat + RAG         code chat/edit/FIM      grammar + lint (no model)    |
  +---------------------------+----------------------------------------------+
                              |  HTTP  POST /api/generate, /api/chat, /api/embeddings
                              v        (OpenAI-compatible endpoints also exposed)
  +--------------------------------------------------------------------------+
  |  ENGINE                                                                   |
  |  Ollama server  (127.0.0.1:11434)                                         |
  |  - loads a model into VRAM (+ RAM offload if needed)                      |
  |  - manages a small model cache, unloads on idle (keep_alive)             |
  |  - exposes generate / chat / embeddings / tags / ps                      |
  +---------------------------+----------------------------------------------+
                              |  reads model blobs from disk
                              v
  +--------------------------------------------------------------------------+
  |  MODEL STORE  (%USERPROFILE%\.ollama\models)                             |
  |  base weights:  qwen2.5:14b  qwen2.5-coder:7b  qwen2.5-coder:1.5b         |
  |  embeddings:    nomic-embed-text                                          |
  |  derived:       nacho-writer (FROM 14b)   nacho-coder (FROM coder:7b)     |
  +--------------------------------------------------------------------------+
```

## 4.3 The engine: Ollama

Ollama is the only long-running service. It wraps `llama.cpp` for inference, manages the
model store, and serves an HTTP API on `127.0.0.1:11434`. Key behaviors worth knowing:

- **Loading.** On the first request for a model, Ollama loads it into VRAM. If the model does
  not fit, it places as many layers as possible on the GPU and runs the rest on the CPU using
  system RAM. The split is visible with `ollama ps` (for example `43%/57% CPU/GPU`).
- **Idle unload.** Models unload after an idle period (`keep_alive`, default a few minutes) to
  free VRAM. The next request reloads them, which is why the first call after a pause is slow.
- **Concurrency.** It can serve generation and embedding requests and can download a model at
  the same time, sharing the disk and CPU.
- **API surface used here.** `POST /api/generate` and `/api/chat` for text, `/api/embeddings`
  for vectors, `GET /api/tags` to list models, `GET /api/ps` for what is loaded. Ollama also
  exposes OpenAI-compatible routes under `/v1`, which some clients prefer.

> [!NOTE]
> The `ollama run` command-line client is convenient interactively but can hang in
> non-interactive or automated contexts. Every front-end here uses the HTTP API, which is
> robust. Prefer the API for any scripting. See [07 Troubleshooting](07-troubleshooting.md).

## 4.4 Models and custom assistants

The base models are open-weight checkpoints pulled from the Ollama registry. The custom
assistants are not new models; they are lightweight layers defined by a **Modelfile** that
sets a base model (`FROM`), a system prompt (`SYSTEM`), and sampling parameters
(`PARAMETER`). Building one with `ollama create` stores a small manifest that references the
base model's blobs, so `nacho-writer` adds almost no disk on top of `qwen2.5:14b`.

| Asset | Defined by | Purpose |
| --- | --- | --- |
| `nacho-writer` | `config/Modelfile.writer` | concise academic prose, your style, low temperature |
| `nacho-coder` | `config/Modelfile.coder` | robotics Python/C++, admits API uncertainty |

This is why retuning the assistant is cheap: edit the Modelfile, run `build_assistants.ps1`,
and the recipe is rebuilt in seconds without re-downloading anything.

## 4.5 The front-ends

- **AnythingLLM** is a desktop application that provides a chat interface and a built-in
  document store with retrieval. It points at Ollama for both generation and embeddings.
- **Continue** is a VS Code extension. Its `config.yaml` assigns models to *roles*: `chat`,
  `edit`, `apply`, `autocomplete`, and `embed`. The autocomplete role uses the small 1.5B
  model so suggestions keep pace with typing; chat and edit use the 7B coder.
- **LTeX+** and **LaTeX Workshop** are VS Code extensions that do not use any model. LTeX+
  embeds LanguageTool for grammar and spelling; LaTeX Workshop builds documents and runs the
  `chktex` linter. They are part of the stack because correctness checking belongs in
  deterministic tools, not a language model.

## 4.6 Retrieval (RAG) data flow

When you "chat with your papers" in AnythingLLM:

```
  document (PDF/tex) --> chunked into passages --> nomic-embed-text --> vectors
                                                                          |
                                                                          v
                                                              local vector store
                                                                          ^
  your question  --> nomic-embed-text --> query vector --> nearest passages
                                                                          |
            question + retrieved passages  -->  nacho-writer / qwen2.5  -->  answer + citations
```

Nothing is sent anywhere. Embedding and generation both happen on your GPU, and the vector
store is a local database inside AnythingLLM. Adding a document re-runs only the embedding
step for that document; no model is retrained.

## 4.7 Where data lives on disk

| Path | Contents |
| --- | --- |
| `%USERPROFILE%\.ollama\models` | model blobs and manifests (large) |
| `%USERPROFILE%\.continue\config.yaml` | Continue's active configuration |
| AnythingLLM app data folder | workspaces, the vector store, chat history |
| this repository | scripts, Modelfiles, configs, docs (no model weights) |

Models are deliberately not stored in the repository; they are pulled by the scripts and live
in Ollama's store. The repo stays small and portable.

## 4.8 What is and is not a runtime dependency

- **Required at runtime:** Ollama (server + a model). That is the whole serving path.
- **Required only at build/install time:** winget (to install Ollama), Git (to clone),
  the model registry (to download weights once).
- **Optional:** AnythingLLM, Continue, LTeX+, LaTeX Workshop, Docker (only for the optional
  LanguageTool server). Each adds a capability; none is needed for the others to work.

The practical consequence: if you only want a chat assistant, you need Ollama and one model,
nothing else. Everything beyond that is additive.
