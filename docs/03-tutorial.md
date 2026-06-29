# 3. Tutorial: your first hour

> A hands-on walkthrough of the four things you will do most: polish writing, write code,
> check a LaTeX document, and chat with your own papers. Assumes you finished
> [02 Installation](02-installation.md).

- [3.1 Pick the right model for the job](#31-pick-the-right-model-for-the-job)
- [3.2 Polish a paragraph](#32-polish-a-paragraph)
- [3.3 Write and edit code in VS Code](#33-write-and-edit-code-in-vs-code)
- [3.4 Check a LaTeX document](#34-check-a-latex-document)
- [3.5 Chat with your papers](#35-chat-with-your-papers)
- [3.6 A sensible daily workflow](#36-a-sensible-daily-workflow)

## 3.1 Pick the right model for the job

| You want to... | Use | Model |
| --- | --- | --- |
| Polish prose, fix tone, tighten text | AnythingLLM or terminal | `nacho-writer` (14B) |
| Ask a control / math / analysis question | AnythingLLM | `qwen2.5:14b` or `nacho-writer` |
| Ask about *your* papers specifically | AnythingLLM workspace + docs | any + `nomic-embed-text` |
| Write or refactor Python/C++ | Continue in VS Code | `qwen2.5-coder:7b` |
| Inline autocomplete | Continue (automatic) | `qwen2.5-coder:1.5b` |
| Catch typos / grammar / LaTeX issues | LTeX+, LaTeX Workshop | none (deterministic) |

Rule of thumb: **7B is the fast daily driver; 14B is slower but writes and reasons better.**
Speeds depend on your GPU; see [06 Models and hardware](06-models-and-hardware.md).

## 3.2 Polish a paragraph

The quickest way to feel the writing assistant is in a terminal:

```powershell
ollama run nacho-writer
```

Paste a wordy sentence and ask for a rewrite, for example:

> Tighten this and keep the physical intuition, no em-dashes: "The proposed controller, which
> is something that is quite novel, has the ability to be able to achieve, in a manner that
> is robust, the convergence of the system to the desired configuration."

A typical result keeps the meaning and removes the padding:

> "The proposed controller achieves robust convergence to the desired configuration."

Type `/bye` to exit. For longer text and back-and-forth, do the same inside AnythingLLM,
which keeps history. Prompts that work well:

- "Rewrite for a concise, technically precise tone: flowing prose, no bullet lists, no
  em-dashes. Keep the math meaning unchanged."
- "Shorten by 30% without losing any technical claim."
- "Give two phrasings of this sentence and say which reads better on first pass."

> [!IMPORTANT]
> The assistant edits words, not mathematics. If a sentence states a mathematical claim, you
> remain the judge of whether it is true.

## 3.3 Write and edit code in VS Code

Open any project in VS Code. The Continue extension is your local coding assistant.

- **Chat:** press `Ctrl+L` to open the panel. Ask "write a C++ function using Eigen that
  projects a point onto a line segment" or "explain what this function does."
- **Edit in place:** select code, press `Ctrl+I`, type an instruction such as "add bounds
  checking and Doxygen comments." Continue shows a diff you accept or reject.
- **Attach context:** type `@` in the chat to attach a file, the current diff, or terminal
  output, so the model sees exactly what it needs.
- **Autocomplete:** as you type, grey ghost-text appears; press `Tab` to accept. This uses
  the small 1.5B model so it keeps up.

Good habits for a local model:

1. Ask for one function or file at a time, not "refactor the whole project."
2. Always read the diff. The output is usually right and occasionally subtly wrong,
   especially around numerics and edge cases.
3. For library APIs (ROS, libfranka, MuJoCo), verify anything that looks uncertain. The
   `nacho-coder` assistant is told to admit uncertainty instead of inventing an API, but
   check anyway.

## 3.4 Check a LaTeX document

Open your `.tex` files in VS Code.

- **LTeX+** underlines spelling and grammar and understands LaTeX commands. Hover a warning
  to see the suggested fix. Add field-specific words (for example "ergodic", "Sobolev") to
  the dictionary with the quick-fix so they stop being flagged.
- **chktex** (via LaTeX Workshop) catches LaTeX-specific issues: spacing around math, a
  missing `~` before `\cite`, inconsistent quotes, and similar.

A workflow that works well: write a section, let LTeX+ and chktex clean the mechanics, then
paste the cleaned paragraph into `nacho-writer` for flow and concision. The deterministic
tools handle correctness; the model handles style.

## 3.5 Chat with your papers

This is how you keep the assistant current with new knowledge, with no retraining: you add
documents and it answers from them.

In AnythingLLM:

1. Create a **Workspace** per topic (for example "deformable-manip", "ergodic-control").
2. Drag in PDFs, `.tex`, or `.bib` files. AnythingLLM indexes them locally using
   `nomic-embed-text`.
3. Ask questions such as "According to the documents here, how does X differ from Y?"
   Answers cite the source files. Add more documents whenever you read something new.

> [!TIP]
> Keep workspaces focused. Five relevant papers give sharper answers than two hundred
> unrelated PDFs in one workspace.

## 3.6 A sensible daily workflow

- Draft in your editor; let LTeX+ and chktex fix mechanics live.
- Use Continue for code, one function at a time, reading every diff.
- Use `nacho-writer` to tighten finished paragraphs.
- Keep a few AnythingLLM workspaces for the literature you are actively working with.
- Keep your proofs and any safety-critical numbers under human verification.

Next: understand what is happening under the hood in [04 Architecture](04-architecture.md),
or tune the assistants to your own voice in [05 Configuration](05-configuration.md).
