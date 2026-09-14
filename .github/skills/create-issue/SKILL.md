---
name: create-issue
description: "Draft and create an issue through this repository's configured issue tracker. Use when asked to create, draft, file, or update an issue or ticket."
argument-hint: "[title] [description]"
---

# Create Issue

Create a well-structured issue from the current conversation and workspace context. Never perform a
write until the user confirms the complete issue draft.

## Dependencies

Read `.github/copilot/project.json` and inspect `capabilities.issueTracker`.

- Missing or invalid manifest, missing capability, or `unconfigured`: stop and run
	`setup-copilot-project` in the main agent.
- `disabled`: stop and state that `issueTracker` must be enabled through `setup-copilot-project`.
- `enabled`: read and follow the referenced operational instructions.

The issue tracker is required for this skill. Do not substitute a browser, REST API, CLI, or tool not
authorized by the operational instructions. Never request or store credentials in repository files.

## Draft

Use supplied arguments first. Derive missing content from the active request, current conversation,
referenced code, specifications, and tests. Ask concise questions for information that cannot be
established from context. Do not invent requirements or use placeholder text.

Prefer these sections when relevant and omit empty sections:

```markdown
## Summary

## Context

## Tasks

## Acceptance Criteria

## Technical Notes
```

Make tasks and acceptance criteria observable. Preserve established identifiers, constraints,
prerequisites, and scope boundaries.

## Confirm and Write

Present every field that will be written, including project or repository, issue type, title,
description, relationships, release or milestone, labels, and priority when applicable. Ask for
explicit confirmation. A request to draft or inspect is not confirmation.

After confirmation, follow the configured create procedure. Read the issue back when the configured
provider supports it and compare all requested fields. Correct only confirmed fields that differ;
never modify unrelated data. Report the final issue reference and any field that could not be set.

## Guardrails

- Check likely duplicates named by the context before creating a new issue.
- Validate referenced issues and selectable values when the configured provider supports validation.
- Do not perform any write-capable operation before confirmation.
- Do not create, edit, transition, assign, or comment outside the requested issue scope.