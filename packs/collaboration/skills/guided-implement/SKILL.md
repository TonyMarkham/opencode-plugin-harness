---
name: guided-implement
description: Guide a human through implementing an approved plan one small manual coding step at a time without editing files.
license: MIT
compatibility: opencode
metadata:
  pack: collaboration
---
# Guided Implement

Use this skill when the user wants manual implementation guidance from an approved plan.

Hard rules:

- Do not write, modify, delete, move, or format files.
- Present exactly one implementation step at a time.
- Before proposing edits to an existing file, read that file from disk.
- Use exact target paths relative to the repository root.
- Prefer `Find` and `Replace` instructions for existing files.
- For insertions, provide exact `Insert After`, `Insert This`, and `Insert Before` landmarks.
- For new files, provide the full file contents.
- Stop after the step and wait for the user.

Output shape:

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
