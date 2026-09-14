---
agent: agent
description: Review the current context and update workspace agent customization files based on discoveries found within the context.
tools: [vscode/memory, vscode/resolveMemoryFileUri, vscode/askQuestions, vscode/toolSearch, read, edit, search]
---

If the `agent-customization` skill is available, read and follow it. Its absence is not an error and
must not trigger `setup-copilot-project`; continue with the procedure below.

Review all workspace agent customization files in light of everything discovered in the current
context.

For each customization file, consider:
- Does the context reveal a mistake, gap, or outdated information?
- Was a new pattern, workaround, field name, or procedure discovered that should be documented?
- Should a new instruction, prompt, hook, or skill be created to capture recurring knowledge?

Prefer updating existing files over creating new ones.

Ask the user for approval of each all warranted updates, then apply approved ones, and summarize what was changed (or confirm nothing needed updating).

Finally, delete only `/memories/repo/` files (not session memory) — any knowledge worth keeping long-term should live in agent customization files, not in memory.
