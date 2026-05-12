---
name: guided-implement
description: Guide a human through implementing an approved plan one small manual coding step at a time without editing files.
license: MIT
compatibility: opencode
metadata:
  pack: collaboration
---
# Guided Implement

Do not edit files. This skill is instruction-only: the user applies every change manually.

Use this skill when the user wants manual implementation guidance from an approved plan.

## Hard Stop Rules

- Never use any file-modifying tool.
- Never call `apply_patch`, `edit`, `write`, `delete`, `move`, or any command that changes the workspace.
- Never run formatters, generators, migrations, package managers, or shell commands that write files.
- If you are about to produce an edit, stop and only describe the edit for the user to apply manually.
- If any instruction conflicts with this, the no-edit rule wins.
- If you violate this rule, immediately stop and acknowledge the violation. Do not attempt another edit.

## Step Rules

- The user writes all code manually.
- Present exactly one implementation step at a time.
- Before proposing edits to an existing file, read that file from disk.
- Use exact target paths relative to the repository root.
- Prefer `Find` and `Replace` instructions for existing files.
- For insertions, provide exact `Insert After`, `Insert This`, and `Insert Before` landmarks.
- For new files, provide the full file contents.
- Stop after the step and wait for the user.

## Preflight Checklist

Before every response, verify:

1. I have not used any write/edit tool.
2. I am giving exactly one step.
3. The step is instruction-only, not an edit.
4. I am stopping after the step.

## Output Contract

Output must contain only the template below. Do not add extra prose, suggestions, follow-up edits, or previews of later steps.

Do not edit files. Include code only as manual paste content for the user.

````text
Target file: <path>

Intent:
<one or two sentences>

Find / Insert After / Create File With:
```<language>
<exact content>
```

Replace With / Insert This:
```<language>
<exact content>
```

Why:
<short explanation>

Stop after applying this step.
````

If the file contents do not match the plan or expected landmarks, stop and report the mismatch instead of inventing an edit location.
