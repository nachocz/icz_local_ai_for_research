# 1. Introduction

> A guided, plain-language explanation of what this project is, why it is built the way it
> is, and who it is for. If you just want to install it, jump to
> [02 Installation](02-installation.md).

## 1.1 What this is

`icz_local_ai` is a setup, not a single program. It connects a handful of mature open-source
tools so that one machine becomes a private AI workstation. After a one-time installation you
have a chat assistant, an in-editor coding assistant, a writing editor tuned for academic
prose, offline grammar and LaTeX checking, and the ability to ask questions over your own
library of PDFs, all running locally.

The design goal is boring on purpose: each piece is a well-known tool used in the ordinary
way, glued together with short, readable scripts. There is no custom server, no hidden
service, and nothing to trust beyond the upstream projects themselves.

## 1.2 The three guarantees

1. **Offline.** After the initial download of the models, the system needs no internet. You
   can pull the network cable and everything still works. This matters on planes, in secure
   environments, and anywhere connectivity is poor.
2. **Free.** There is no subscription and no per-token cost. The models are open-weight and
   the tools are open-source. The only resource you spend is your own electricity and disk.
3. **Private.** Your drafts, code, and questions never leave the machine. For unpublished
   research and proprietary code this is the difference between a usable tool and a
   compliance problem.

## 1.3 Why local models are good enough now

A few years ago, a useful assistant meant a frontier model in a data center. That is no
longer the only option. Open-weight models in the 7-to-14-billion-parameter range, run on a
consumer GPU, are now strong at a large slice of everyday technical work:

- recalling and explaining standard theory (control, estimation, linear algebra, analysis),
- drafting and rewriting prose,
- writing and explaining code in mainstream languages and libraries,
- summarizing and answering questions over documents you supply.

They are not frontier models, and the documentation is careful to say where they fall short
(see [1.5](#15-honest-limits)). But for the daily grind of a research engineer, the gap that
matters has largely closed.

## 1.4 Who this is for

The project was built by and for a robotics control researcher, so the default writing style
and the coding assistant lean that way. It will suit you well if you:

- write technical documents (papers, theses, reports) and want a private editor,
- write Python and C++ for research or engineering,
- want a quick, offline reference for standard theory,
- care about owning your tools and data.

It is equally useful to anyone who wants a private, offline, no-cost assistant and is willing
to spend an hour setting it up. The writing style and the assistants are easy to retune to a
different field or voice (see [05 Configuration](05-configuration.md)).

## 1.5 Honest limits

This is stated up front because overselling a local model is how people get burned.

- **It will not verify your math.** A local 7-14B model produces fluent, confident, and
  sometimes wrong algebra. Treat any derivation it offers as a draft to check, never as a
  proof. The writing assistant is explicitly instructed to flag suspicious math rather than
  silently "fix" it, but the responsibility stays with you.
- **It is not a frontier coder.** It writes good individual functions and explains code well.
  It does not reason reliably over a whole codebase, and it can miss subtle numerical or
  concurrency bugs. Read its diffs the way you would read a capable junior's pull request.
- **Speed scales with model size and your GPU.** A 7B model is fast; a 14B model that has to
  spill into system RAM is slower. [06 Models and hardware](06-models-and-hardware.md)
  explains how to pick the right size for your machine.

Used within these limits, it is genuinely productive. Used outside them, it will mislead you.

## 1.6 What to read next

- New here and want it working: [02 Installation](02-installation.md).
- Want a feel for daily use first: [03 Tutorial](03-tutorial.md).
- Want to understand the machinery: [04 Architecture](04-architecture.md).
