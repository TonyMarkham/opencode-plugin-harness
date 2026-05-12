# opencode-plugin-harness

Reusable OpenCode harness packs for controlled collaboration workflows.

This repository is not an OpenCode marketplace. OpenCode does not currently import marketplace catalogs from GitHub. Instead, this repo is intended to be added to a project as a submodule, then linked into that project's `.opencode/` directory.

## Install As Submodule

From the target repository:

```bash
git submodule add https://github.com/TonyMarkham/opencode-plugin-harness.git vendor/opencode-plugin-harness
```

Then install the default collaboration pack entries:

```bash
bash vendor/opencode-plugin-harness/install.sh --pack collaboration --target .
```

Windows PowerShell:

```powershell
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -Target .
```

The PowerShell installer defaults to `-Mode auto`. On Windows, auto mode uses directory junctions for skill directories and falls back to copying file entries when file symlinks require administrator privileges or Developer Mode.

The installer creates `.opencode/agents`, `.opencode/skills`, and `.opencode/commands` when needed, then links selected pack entries into those directories.

## Use Guided Implementation

Prefer the command or no-edit agent so OpenCode applies guided implementation permissions, not just the skill text:

```text
/guided-implement path/to/plan.md
```

or:

```text
@guided-implement Use the guided-implement skill on path/to/plan.md.
```

Calling `Use the guided-implement skill...` from a permissive build/edit agent may load the skill text without removing that agent's file-edit permissions.

## Install Specific Entries

```bash
bash vendor/opencode-plugin-harness/install.sh --pack collaboration --skill colab-audit-plan
bash vendor/opencode-plugin-harness/install.sh --pack collaboration --agent audit-plan
bash vendor/opencode-plugin-harness/install.sh --pack collaboration --all
```

PowerShell:

```powershell
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -Name colab-audit-plan
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -Kind agent -Name audit-plan
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -All
```

## Copy Fallback

Symlinks can require extra permissions on Windows. If you want to avoid links entirely, use copy mode:

```bash
bash vendor/opencode-plugin-harness/install.sh --pack collaboration --copy
```

```powershell
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -Mode copy
```

Copy mode is safer for environments that do not support symlinks, but copied prompts can become stale when the submodule is updated.

To require symlinks and fail instead of falling back, use strict link mode:

```powershell
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -Mode link
```

## Pack Manifest

Each pack has a `pack.toml` that lists installable affordances:

- `agent`: OpenCode agent markdown files
- `skill`: OpenCode `SKILL.md` directories
- `command`: OpenCode command markdown files
- `plugin`: OpenCode JS/TS plugin files, when needed

The installer intentionally links individual entries instead of whole directories so projects can keep repo-local agents, skills, and commands beside harness-provided ones.
