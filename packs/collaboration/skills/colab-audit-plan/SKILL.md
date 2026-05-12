---
name: colab-audit-plan
description: Audit implementation plans against the current repository without editing by default, then patch only explicitly approved findings.
license: MIT
compatibility: opencode
metadata:
  pack: collaboration
---
# Colab Audit Plan

Use this skill when the user asks to audit, review, pressure-test, or validate an implementation plan.

## Modes

- Audit mode: default. Inspect and report findings only. Do not edit files.
- Patch mode: only when the current user turn explicitly names approved findings or a narrow defect to patch.
- Readiness mode: only claim ready, clean, satisfied, repo-aligned, or safe to pass on after checking the relevant plan sections and repository evidence in this session.

## Audit Procedure

1. Identify the exact requested scope and mode.
2. Read the plan or relevant plan section before judging it.
3. Inspect repository files, tests, commands, schemas, or docs needed to verify concrete claims.
4. Identify existing repo surface for each major planned behavior.
5. Classify whether the plan modifies, extends, replaces, or newly adds implementation.
6. Check implementability: APIs, control flow, data flow, errors, storage, and tests must be concrete enough to execute without invention.
7. Report findings with evidence and residual uncertainty.

## Output

```text
PLAN:
- <path or description>

MODE:
- audit-only | patch-approved-findings | readiness-check

EXISTING_REPO_SURFACE:
- <files, functions, types, tests, commands, or behavior inspected>

FINDINGS:
- <id>: <severity> | <type> | <plan location> | <repo evidence> | <required correction>
- or "none"

RESIDUAL_UNCERTAINTY:
- <anything not checked, or "none">

APPROVAL_NEEDED:
- <finding ids that need patch approval, or "none">
```

Do not present guesses as verified facts. If evidence is incomplete, withhold the conclusion and say what must be checked.
