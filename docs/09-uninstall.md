# 9. Uninstall and cleanup

> How to remove part or all of the framework and reclaim disk space. Nothing here is
> destructive to your own documents; it removes only what `icz_local_ai` installed. A helper
> script, `scripts/uninstall.ps1`, automates the command-line parts with confirmation
> prompts.

- [9.1 What gets installed, and where](#91-what-gets-installed-and-where)
- [9.2 Reclaim space without uninstalling](#92-reclaim-space-without-uninstalling)
- [9.3 Full uninstall, step by step](#93-full-uninstall-step-by-step)
- [9.4 The helper script](#94-the-helper-script)
- [9.5 Verify everything is gone](#95-verify-everything-is-gone)

## 9.1 What gets installed, and where

| Component | Installed by | Lives in |
| --- | --- | --- |
| Ollama engine | winget | `%LOCALAPPDATA%\Programs\Ollama`, logs in `%LOCALAPPDATA%\Ollama` |
| Models and custom assistants | `ollama pull` / `ollama create` | `%USERPROFILE%\.ollama` (the large folder) |
| Continue extension | VS Code | VS Code extensions folder |
| Continue config | this project | `%USERPROFILE%\.continue` |
| LaTeX Workshop, LTeX+ | VS Code | VS Code extensions folder |
| AnythingLLM | desktop installer | Program Files + app data under `%APPDATA%` |
| LanguageTool (optional) | Docker | a Docker container and image |
| The framework itself | `git clone` | the folder you cloned into |

The bulk of the disk use is the models in `%USERPROFILE%\.ollama` (roughly 15 GB for the
default set). If you only want space back, see the next section.

## 9.2 Reclaim space without uninstalling

Remove individual models you do not use but keep the engine and the rest:

```powershell
ollama list                       # see what you have and the sizes
ollama rm qwen2.5:14b             # remove a specific model
ollama rm nacho-writer            # remove a custom assistant
```

Custom assistants are tiny (they reference a base model), so removing them saves little. The
space is in the base models.

## 9.3 Full uninstall, step by step

Run these from any terminal. Each step is independent; skip any you want to keep.

### Step 1 - Remove models and custom assistants

The simplest complete removal is to delete Ollama's whole store in step 2. To remove just the
models first:

```powershell
ollama rm nacho-writer nacho-coder
ollama rm qwen2.5:14b qwen2.5-coder:7b qwen2.5-coder:1.5b nomic-embed-text
```

### Step 2 - Uninstall the Ollama engine and its data

```powershell
winget uninstall --id Ollama.Ollama -e
Remove-Item -Recurse -Force "$env:USERPROFILE\.ollama"      # the model store (large)
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Ollama"      # logs (if present)
```

> [!WARNING]
> Deleting `%USERPROFILE%\.ollama` removes every model you pulled, including any you added
> yourself. This is the step that frees the most disk.

### Step 3 - Remove the VS Code extensions

```powershell
code --uninstall-extension Continue.continue
code --uninstall-extension James-Yu.latex-workshop
# LTeX+ has a versioned id; find and remove it:
code --list-extensions | Select-String -Pattern "ltex"
# then, using the id printed above, for example:
# code --uninstall-extension ltex-plus.vscode-ltex-plus
```

### Step 4 - Remove the Continue configuration

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.continue"
```

### Step 5 - Uninstall AnythingLLM

AnythingLLM is a desktop app. Uninstall it from **Settings, Apps, Installed apps** (search
"AnythingLLM"), or with winget if you installed it that way:

```powershell
winget uninstall "AnythingLLM"
```

Then remove its leftover data (the folder name can vary slightly by version, so check both):

```powershell
Get-ChildItem "$env:APPDATA","$env:LOCALAPPDATA" -Filter "*anythingllm*" -Directory -ErrorAction SilentlyContinue
# remove any folder it lists, for example:
# Remove-Item -Recurse -Force "$env:APPDATA\anythingllm-desktop"
```

> [!NOTE]
> This deletes your AnythingLLM workspaces and the document index. Your original PDFs are not
> touched; only the copies and vectors AnythingLLM created are removed.

### Step 6 - Remove the optional LanguageTool container

Only if you ran `scripts/start_languagetool.ps1`:

```powershell
docker stop languagetool
docker rm languagetool
docker rmi erikvl87/languagetool
```

If you also test-built the documentation site locally, you can drop that image too:

```powershell
docker rmi squidfunk/mkdocs-material
```

### Step 7 - Delete the framework folder

Finally, delete the folder you cloned. Do this from outside the folder:

```powershell
Remove-Item -Recurse -Force "path\to\icz_local_ai_for_research"
```

### Step 8 - Optional: revert the script execution policy

If you set it during installation and want it back to the default:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Undefined
```

## 9.4 The helper script

`scripts/uninstall.ps1` performs the command-line steps (1-4 and 6) with confirmation
prompts. It never deletes your documents and never touches AnythingLLM or the repo folder,
which are left for you to remove by hand.

```powershell
# show what each option does (default, removes nothing):
./scripts/uninstall.ps1

# remove only the models and custom assistants:
./scripts/uninstall.ps1 -Models

# remove everything it can, with a single confirmation:
./scripts/uninstall.ps1 -All -Yes
```

Options: `-Models`, `-Engine`, `-Extensions`, `-Config`, `-LanguageTool`, `-All`, and `-Yes`
(skip the per-step confirmation). Without any option it only prints the plan.

## 9.5 Verify everything is gone

```powershell
Get-Command ollama -ErrorAction SilentlyContinue   # nothing = engine removed
Test-Path "$env:USERPROFILE\.ollama"               # False = models removed
Test-Path "$env:USERPROFILE\.continue"             # False = Continue config removed
code --list-extensions | Select-String "continue|latex-workshop|ltex"   # empty = extensions removed
```

If all of those come back empty or `False`, the framework is fully removed.
