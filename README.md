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

The installer creates `.opencode/agents`, `.opencode/skills`, and `.opencode/commands` when needed, then links selected pack entries into those directories.

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

Symlinks can require extra permissions on Windows. If linking fails, use copy mode:

```bash
bash vendor/opencode-plugin-harness/install.sh --pack collaboration --copy
```

```powershell
.\vendor\opencode-plugin-harness\install.ps1 -Pack collaboration -Mode copy
```

Copy mode is safer for environments that do not support symlinks, but copied prompts can become stale when the submodule is updated.

## Pack Manifest

Each pack has a `pack.toml` that lists installable affordances:

- `agent`: OpenCode agent markdown files
- `skill`: OpenCode `SKILL.md` directories
- `command`: OpenCode command markdown files
- `plugin`: OpenCode JS/TS plugin files, when needed

The installer intentionally links individual entries instead of whole directories so projects can keep repo-local agents, skills, and commands beside harness-provided ones.
