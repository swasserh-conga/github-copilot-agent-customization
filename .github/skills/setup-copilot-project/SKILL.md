---
name: setup-copilot-project
description: "Configure this repository for the reusable Copilot customizations. Use when setup is requested or when .github/copilot/project.json is absent, outdated, invalid, or has an unconfigured capability."
argument-hint: "[capability name] (optional)"
---

# Setup Copilot Project

Configure the repository-specific information consumed by the customizations in this repository.
Configuration is committed under `.github/copilot/`. Never collect or store passwords, tokens,
credentials, private keys, or other secrets.

## Configuration Contract

`.github/copilot/project.json` is the manifest. Supported capability states are `unconfigured`,
`enabled`, and `disabled`.

- `issueTracker` points to `.github/copilot/issue-tracker.md` when enabled.
- `gitServer` points to `.github/copilot/git-server.md` when enabled.
- `grilling` names the customization that implements grilling. Its default is `grill-me-on`.
- `conciseStyle` optionally names a customization that provides an unusually terse writing style.

Operational Markdown describes how agents perform provider-specific operations. The manifest stores
only state, short metadata, and customization names. It contains no tool names whose signatures are
assumed to be portable.

## Process

### 1. Inspect

Read the current manifest and any existing files under `.github/copilot/`. Inspect repository facts
that can answer setup questions, including Git remotes, repository instructions, and available tools
and customizations. Do not ask for information that can be established from the workspace.

If `schemaVersion` is lower than `1`, migrate interactively and preserve recognized values. If it is
higher than `1`, stop without editing because this skill may not understand the newer schema.

If the manifest is invalid JSON, has no integer `schemaVersion`, uses malformed capability blocks, or
has invalid version 1 values, reconstruct a complete version 1 draft interactively. Preserve only
recognized values whose types and referenced files are valid; present every discarded value and its
reason. Do not overwrite the malformed file until the user confirms the complete replacement draft.

### 2. Choose Capabilities

For initial setup, ask the user which optional external integrations to enable:

- Issue tracker
- Git server and pull requests

Selected integrations become `enabled`; unselected integrations become `disabled`. When updating a
single capability, leave all others unchanged.

Then ask only for information needed by enabled capabilities. Prefer a detected value and identify it
as the recommended answer. Accept provider-neutral freeform procedures when no supported tool or CLI
can be inferred.

For customization routing:

- Keep `grill-me-on` unless the user explicitly chooses another visible customization.
- Leave `conciseStyle` disabled unless the user explicitly enables it.
- Resolve a replacement name against all customizations visible to the current agent. Require exactly
  one match. Reject an absent or ambiguous explicit choice; never silently fall back.

### 3. Draft Operational Files

For an enabled issue tracker, draft `.github/copilot/issue-tracker.md` with only applicable sections:

```markdown
# Issue Tracker

## Identity
## Issue References
## Read an Issue
## Create an Issue
## Update an Issue
## Links
## Constraints
```

For an enabled Git server, draft `.github/copilot/git-server.md` with only applicable sections:

```markdown
# Git Server

## Repository
## Read a Pull Request
## Read Changes and Feedback
## Links
## Push Safety
## Constraints
```

Write executable agent guidance: identify the available tools or CLI, required arguments, expected
results, and safe fallback. Use generic headings even when the selected provider is vendor-specific.
Do not invent an operation that the user did not describe and the repository does not establish.

When a capability is disabled, delete its generated operational file if it exists and the user
confirms removal. A disabled capability must not leave instructions that appear active.

### 4. Confirm and Write

Show the complete proposed manifest and every operational file that will be created, updated, or
deleted. Ask for one final confirmation. Do not write partial configuration before confirmation.

On confirmation:

1. Write the operational Markdown files.
2. Write `.github/copilot/project.json` last, with `schemaVersion` set to `1`.
3. Parse the JSON after writing.
4. Verify that every enabled integration references an existing operational file.
5. Report enabled, disabled, and still-unconfigured capabilities.

The skill may be rerun to update one capability or to verify the current setup. Preserve unrelated
user edits and values.

## Consumer Rules

Consumers inspect the manifest before using a configurable capability:

- Required + `unconfigured`: stop before delegation and run this skill in the main agent.
- Required + `disabled`: stop and name the disabled capability.
- Optional + `unconfigured`: run this skill before delegation when the capability is relevant.
- Optional + `disabled`: skip that part and state that it was not configured.
- Enabled: read and follow the referenced operational Markdown.

An explicitly configured customization that cannot be resolved is invalid configuration. Required
consumers stop; optional consumers skip and report the invalid name.